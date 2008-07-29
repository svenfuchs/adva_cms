class User < ActiveRecord::Base
  acts_as_authenticated_user
  
  has_many :sites, :through => :memberships
  has_many :memberships, :dependent => :delete_all
  has_many :roles, :dependent => :delete_all do
    def by_context(object)
      roles = by_site object
      # TODO in theory we could skip the implicit roles here if roles were already found
      # ... assuming that any site roles always include any implicit roles.
      roles += object.implicit_roles(proxy_owner) if object.respond_to? :implicit_roles
      roles
    end
    
    def by_site(object)
      site = object.is_a?(Site) ? object : object.site
      sql = "type = 'Role::Superuser' OR 
             context_id = ? AND context_type = 'Site' OR 
             context_id IN (?) AND context_type = 'Section'"
      find :all, :conditions => [sql, site.id, site.section_ids]
    end
  end
  
  validates_presence_of     :name, :email, :login
  validates_uniqueness_of   :name, :email, :login # i.e. account attributes are unique per application, not per site
  validates_length_of       :name, :within => 1..40
  validates_format_of       :email, :with => /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i

  validates_presence_of     :password, :password_confirmation, :if => :password_required?
  validates_length_of       :password, :within => 4..40,       :if => :password_required?
  validates_confirmation_of :password,                         :if => :password_required?

  class << self
    def authenticate(credentials)
      return false unless user = User.find_by_login(credentials[:login])
      user.authenticate(credentials[:password]) ? user : false
    end

    def superusers
      find :all, :include => :roles, :conditions => ['roles.type = ?', 'Role::Superuser']
    end
    
    def admins_and_superusers
      find :all, :include => :roles, :conditions => ['roles.type IN (?)', ['Role::Superuser', 'Role::Admin']]
    end
    
    def create_superuser(params)
      user = User.new(params)
      user.verified_at = Time.zone.now
      user.send :assign_password
      user.save false
      user.roles << Role::Superuser.create!
      user
    end
  end
  
  # Using callbacks for such lowlevel things is just awkward. So let's hook in here.
  def attributes=(attributes)
    attributes.symbolize_keys!
    roles = attributes.delete :roles
    returning super do update_roles roles if roles end
  end
  
  def update_roles(roles)
    self.roles.clear
    roles.values.each do |role|
      next unless role.delete('selected') == '1'
      self.roles << Role.create!(role)
    end
  end
  
  def verified?
    !verified_at.nil?
  end
  
  def verified!
    update_attributes :verified_at => Time.zone.now if verified_at.nil?
  end
  
  def restore!
    update_attributes :deleted_at => nil if deleted_at
  end
  
  def anonymous?
    false
  end
  
  def registered?
    !new_record?
  end
  
  def has_role?(role, object = nil)
    role = Role.build role, object unless role.is_a? Role
    role.applies_to?(self) || !!roles.detect {|r| r.includes? role }
  end
  
  def has_exact_role?(name, object = nil)
    role = Role.build(name, object)
    role.applies_to?(self) || !!roles.detect {|r| r == role }
  end
    
  def to_s
    name
  end
  
  protected
  
    def password_required?
      password_hash.nil? || !password.blank?
    end
end