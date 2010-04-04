class Invitation < ActiveRecord::Base
  
  belongs_to :site

  validates_presence_of :email, :token
  validates_format_of :roles, :with => /^([a-z]*|[a-z]+(( ){1}[a-z]+)*)$/
  
  before_validation_on_create :generate_token
  
  def set_roles(roles_attr_hash = nil)
    roles_attrs = roles_attr_hash.map { |key, value| value } if roles_attr_hash
    selected_roles = []
    roles_attrs.each do |role_attr| 
      selected_roles << role_attr['name'] if role_attr['selected'] == '1'
    end
    self.roles = selected_roles.join(' ')
  end
  
  private

  def generate_token
    self.token = SHA1.hexdigest(self.email+Time.now.to_s)
  end

end