module SpecRolesHelper
  def define_roles!
    Rbac::Role.define :anonymous, 
                      :grant => true
                      
    Rbac::Role.define :user, 
                      :grant => :registered?, 
                      :parent => :anonymous,
                      :message => 'You need to be logged in to perform this action.'

    Rbac::Role.define :author, 
                      :require_context => Comment, 
                      :grant => lambda{|context, user| context && !!context.try(:is_author?, user) }, 
                      :parent => :user,
                      :message => 'You need to be the author of this object to perform this action.'

    Rbac::Role.define :moderator, 
                      :require_context => Section, 
                      :parent => :author,
                      :message => 'You need to be a moderator to perform this action.'

    Rbac::Role.define :admin,
                      :require_context => Site, 
                      :parent => :moderator,
                      :message => 'You need to be an admin to perform this action.'

    Rbac::Role.define :owner,
                      :require_context => Account, 
                      :parent => :admin,
                      :message => 'You need to be the owner of this account to perform this action.'

    Rbac::Role.define :superuser, 
                      :parent => :owner,
                      :message => 'You need to be a superuser to perform this action.'
  end
end