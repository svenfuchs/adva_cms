class User < ActiveRecord::Base
  acts_as_authenticated_user

  # TODO how do we work this in?
  #  acts_as_authenticated_user :token_with => 'Authentication::SingleToken',
  #                             :authenticate_with => nil
  
  named_scope :verified,      :conditions => "users.verified_at IS NOT NULL"

  belongs_to :account
  has_many :sites, :through => :memberships
  has_many :memberships, :dependent => :delete_all
  has_many :roles, :dependent => :delete_all, :class_name => 'Rbac::Role::Base' do
    def by_context(object)
      roles = by_site object
      # TODO in theory we could skip the implicit roles here if roles were already found
      # ... assuming that any site roles always include any implicit roles.
      roles += object.implicit_roles(proxy_owner) if object.respond_to? :implicit_roles
      roles
    end

    def by_site(object)
      site = object.is_a?(Site) ? object : object.site
      sql = "type = 'Rbac::Role::Superuser' OR
             context_id = ? AND context_type = 'Content' OR
             context_id IN (?) AND context_type = 'Section'"
      find :all, :conditions => [sql, site.id, site.section_ids]
    end
  end

  validates_presence_of     :first_name, :email
  validates_uniqueness_of   :email # i.e. account attributes are unique per application, not per site
  validates_length_of       :first_name, :within => 1..40
  validates_length_of       :last_name, :allow_nil => true, :within => 0..40
  validates_format_of       :email, :allow_nil => true,
    :with => /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i

  validates_presence_of     :password,                         :if => :password_required?
  validates_length_of       :password, :within => 4..40,       :if => :password_required?

  class << self
    def authenticate(credentials)
      return false unless user = User.find_by_email(credentials[:email])
      user.authenticate(credentials[:password]) ? user : false
    end

    def superusers
      find :all, :include => :roles, :conditions => ['roles.type = ?', 'Rbac::Role::Superuser']
    end

    def admins_and_superusers
      find :all, :include => :roles, :conditions => ['roles.type IN (?)', ['Rbac::Role::Superuser', 'Rbac::Role::Admin']]
    end

    def create_superuser(params)
      user = User.new(params)
      user.verified_at = Time.zone.now
      
      user.email = 'admin@example.org' if user.email.blank?
      user.password = 'admin' if user.password.blank?
      user.first_name = user.first_name_from_email
      
      user.send :assign_password # necessary because we bypass the validation hook
      user.save false
      user.roles << Rbac::Role::Superuser.create!
      user
    end

    def by_context_and_role(context, role)
      return superusers if (role = role.to_s.classify) == 'Superuser'
      find(:all, :include => :roles, :conditions => ["roles.context_type = ? AND roles.context_id = ? AND roles.type = ?", context.class.to_s, context.id, "Rbac::Role::#{role}"])
    end

    def anonymous(attributes = {})
      attributes[:anonymous] = true
      new attributes
    end
  end

  # Using callbacks for such lowlevel things is just awkward. So let's hook in here.
  def attributes=(attributes)
    attributes.symbolize_keys!
    roles = attributes.delete :roles
    memberships = attributes.delete :memberships
    returning super do
      update_roles roles if roles
      update_memberships memberships if memberships
    end
  end

  def update_roles(roles)
    # FIXME clearing all roles is a problem when, e.g., an admin assigns a moderator role to a superuser
    # the superuser will then have lost his superuser role
    self.roles.clear 
    roles.values.each do |role|
      next unless role.delete('selected') == '1'
      self.roles << role.delete('type').constantize.create!(role)
    end
  end

  def update_memberships(memberships)
    memberships.each do |site_id, active|
      site = Site.find site_id
      if active
        self.sites << site unless is_site_member?(site)
      else
        self.sites.delete site if is_site_member?(site)
      end
    end
  end

  def verified?
    !verified_at.nil?
  end

  def verify!
    update_attributes :verified_at => Time.zone.now if verified_at.nil?
  end

  # def restore!
  #   update_attributes :deleted_at => nil if deleted_at
  # end

  def registered?
    !new_record? && !anonymous?
  end

  def has_role?(role, options = {})
    inherit = options.delete(:inherit)
    role = Rbac::Role.build role, options unless role.is_a? Rbac::Role::Base
    role.granted_to? self, options.merge(:inherit => inherit||true)
  end

  def has_exact_role?(name, object = nil)
    role = Rbac::Role.build(name, object)
    role.exactly_granted_to? self
  end

  def is_site_member?(site)
    self.sites.include? site
  end

  def name=(name)
    self.first_name = name
  end

  def name
    last_name ? "#{first_name} #{last_name}" : first_name
  end

  def to_s
    name
  end
  
  def email_with_name
    "#{name} <#{email}>"  
  end
  
  def homepage
    return nil unless self[:homepage]
    
    self[:homepage][0..6] == 'http://' ? self[:homepage] : 'http://' + self[:homepage]
  end

  def first_name_from_email
    self.first_name.blank? && self.email ? self.email.split('@').first : self.first_name
  end

  protected

    def password_required?
      !anonymous? && (password_hash.nil? || password.present?)
    end
end
