class Anonymous < ActiveRecord::Base
  set_table_name :anonymouses # wtf

  acts_as_authenticated_user :token_with => 'Authentication::SingleToken',
                             :authenticate_with => nil

  validates_presence_of :name, :email
  validates_length_of   :name, :within => 3..40
  validates_format_of   :email, :with => /(\A(\s*)\Z)|(\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z)/i

  # TODO - don't we need this anymore?
  #
  # def authenticate(credentials)
  #   return false unless anonymous = Anonymous.find_by_login(credentials[:login])
  #   anonymous.authenticate(credentials[:password]) ? account : false
  # end

  # def has_role?(role, object = nil)
  #   role = Rbac::Role.build role, :context => object unless role.is_a? Rbac::Role
  #   role.granted_to?(self) || role.instance_of?(Rbac::Role::Anonymous)
  # end

  def has_role?(role, options = {})
    role = Rbac::Role.build role, options unless role.is_a? Rbac::Role::Base
    role.granted_to?(self) || role.instance_of?(Rbac::Role::Anonymous)
  end

  def anonymous?
    true
  end

  def registered?
    false
  end
end
