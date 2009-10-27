Role = Rbac::Role

ActionController::Dispatcher.to_prepare do
  User.class_eval do
    acts_as_role_subject

    has_many :roles, :dependent => :delete_all, :class_name => 'Rbac::Role' do
      def by_context(object)
        roles = by_site object
        # TODO in theory we could skip the implicit roles here if roles were already found
        # ... assuming that any site roles always include any implicit roles.
        # roles += object.implicit_roles(proxy_owner) if object.respond_to? :implicit_roles
        roles
      end
    
      def by_site(object)
        site = object.is_a?(Site) ? object : object.site
        sql = "name = 'superuser' OR
               context_id = ? AND context_type = 'Site' OR
               context_id IN (?) AND context_type = 'Section'"
        find :all, :conditions => [sql, site.id, site.section_ids]
      end
    end
    
    class << self
      # ?
      def admins_and_superusers
        find :all, :include => :roles, :conditions => ['roles.name IN (?)', ['superuser', 'admin']]
      end

      def create_superuser(params)
        user             = User.new(params)
        user.verified_at = Time.zone.now
      
        user.email       = 'admin@example.org' if user.email.blank?
        user.password    = 'admin' if user.password.blank?
        user.first_name  = user.first_name_from_email
      
        user.send(:assign_password) # necessary because we bypass the validation hook
        user.save(false)
        user.roles.create!(:name => 'superuser') # FIXME?
        user
      end

      def by_role_and_context(role, context = nil)
        type = Rbac::RoleType.build(role)
        conditions = if type.requires_context?
          ["roles.context_type = ? AND roles.context_id = ? AND roles.name = ?", context.class.to_s, context.id, type.name]
        else
          ["roles.name = ?", type.name]
        end
        find(:all, :include => :roles, :conditions => conditions)
      end
    
      def role_matches_attributes?(attrs, role)
        # FIXME remove symbolize_keys here
        keys = [:name, :context_type, :context_id]
        attrs.symbolize_keys.values_at(*keys).compact.map(&:to_s) == role.attributes.symbolize_keys.values_at(*keys).compact.map(&:to_s)
      end
    end

    def roles_attributes=(roles_attributes)
      selected_roles(roles_attributes).each { |role| self.roles << role }
      unselected_roles(roles_attributes).each { |role| role.destroy }
    end
    
    def selected_roles(roles_attributes = [])
      # FIXME deep_stringify roles_attributes here
      roles_attributes.collect do |attrs|
        next unless attrs['selected'].to_i == 1
        Rbac::Role.new(attrs.except('selected')) unless roles.any? { |role| self.class.role_matches_attributes?(attrs, role) }
      end.compact
    end
    
    def unselected_roles(roles_attributes = [])
      roles.select do |role|
        roles_attributes.any? { |attrs| attrs['selected'].to_i == 0 && self.class.role_matches_attributes?(attrs, role) }
      end
    end
  end
end