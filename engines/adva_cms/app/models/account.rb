class Account < ActiveRecord::Base

  acts_as_role_context

  has_many :superuser_roles, :class_name => 'Role', :foreign_key => 'ancestor_context_id', :conditions => {:name => 'superuser'}
  has_many :superusers, :through => :superuser_roles, :source => :user
  has_many :sites

  validates_presence_of :name

  def self.page_cache_directory_for_site(site)
    environment_specific_path = if Rails.env == 'test'
      'tmp'
    else
      'public'
    end
    "#{Rails.root}/#{environment_specific_path}/cache/#{site.host}"
  end

  def owners
    [self]
  end

  def privileged_account_members
    condition = [
      %{
        roles.ancestor_context_type = ? AND
        roles.ancestor_context_id = ?
      }, self.class.name, id]
    User.find :all, :joins => :roles, :conditions => condition
  end

end
