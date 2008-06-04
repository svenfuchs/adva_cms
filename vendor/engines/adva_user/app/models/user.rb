class User < ActiveRecord::Base
  acts_as_paranoid
  acts_as_authenticated_user
  
  validates_presence_of     :name, :email, :login
  validates_uniqueness_of   :name, :email, :login # i.e. account attributes are unique per application, not per site
  validates_length_of       :name, :within => 1..40
  validates_format_of       :email, :with => /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i

  validates_presence_of     :password, :password_confirmation, :if => :password_required?
  validates_length_of       :password, :within => 4..40,       :if => :password_required?
  validates_confirmation_of :password,                         :if => :password_required?

  has_many :sites, :through => :memberships
  has_many :memberships, :dependent => :delete_all
  has_many :roles, :dependent => :delete_all
  
  after_save :save_roles
  
  class << self
    def authenticate(credentials)
      return false unless user = User.find_by_login(credentials[:login])
      user.authenticate(credentials[:password]) ? user : false
    end

    def superusers
      find :all, :include => :roles, :conditions => ['roles.name = ?', 'superuser']
    end
    
    def create_superuser(params)
      returning User.new(params) do |user|
        user.verified_at = Time.zone.now
        user.send :assign_password
        user.save false
        user.roles << Role.create!(:name => 'superuser')
      end
    end
  end
  
  def update_attributes(attributes)
    @new_roles = attributes.delete('roles')
    super
  end

  def verified!
    update_attributes :verified_at => Time.zone.now if verified_at.nil?
  end
  
  def restore!(token)
    if deleted_at && token && authenticate(token.split(';').last)
      self.deleted_at = nil
      save!
    end
  end
  
  def anonymous?
    false
  end
  
  def registered?
    !new_record?
  end
  
  def has_role?(name, object = nil)
    name = name.to_sym
    return true if name == :anonymous or name == :user && registered?
    object ? object.user_has_role?(self, name) : !!detect_role(name)
  end
  
  def has_exact_role?(name, object = nil)
    name = name.to_sym
    name == :user ? !new_record? : !!detect_exact_role(name, object)
  end
  
  def detect_role(name, object = nil)
    name = name.to_sym
    roles.detect {|role| role.includes? name, object }
  end
  
  def detect_exact_role(name, object = nil)
    name = name.to_sym
    roles.detect {|role| role.is? name.to_sym, object }
  end
    
  def to_s
    name
  end
  
  protected
  
    def password_required?
      password_hash.nil? || !password.blank?
    end  
  
    def save_roles
      return unless @new_roles
      roles.clear
      @new_roles.each do |name, objects|
        objects = {nil => {nil => objects}} unless objects.is_a? Hash
        objects.each do |object_type, object_ids|
          object_ids.each do |object_id, set|
            next unless set == '1'
            roles << Role.create!(:name => name, :object_id => object_id, :object_type => object_type)
          end
        end
      end
      @new_roles = nil      
    end
end