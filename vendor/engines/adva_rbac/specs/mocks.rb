class Account < ActiveRecord::Base
  acts_as_role_context_2
  attr_accessor :permissions
end

class Site < ActiveRecord::Base
  acts_as_role_context_2 :actions => ["manage themes", "manage assets"],
                         :roles => [:admin],
                         :parent => Account

  belongs_to :account
  attr_accessor :permissions
end

class Section < ActiveRecord::Base
  acts_as_role_context_2 :actions => ["create article", "update article", "delete article"],
                         :roles => [:moderator],
                         :parent => Site

  belongs_to :site
  attr_accessor :permissions
end

class Content < ActiveRecord::Base
  acts_as_role_context_2 :roles => [:author],
                         :parent => Section

  belongs_to :section
  attr_accessor :permissions
end

class Comment < ActiveRecord::Base
  acts_as_role_context_2 :roles => [:author],
                         :parent => Content

  belongs_to :content
  attr_accessor :permissions
end

class User < ActiveRecord::Base
  belongs_to :account
  has_many :roles, :class_name => 'Rbac::Role::Base'

  def has_role?(role, options = {})
    role = Rbac::Role.build role, options unless role.is_a? Rbac::Role::Base
    role.granted_to? self
  end

  def has_exact_role?(name, object = nil)
    role = Role.build(name, object)
    role.exactly_granted_to? self
    # role.applies_to?(self) || !!roles.detect {|r| r == role }
  end
  
end

Rbac::Context.permissions = { :'create article' => :superuser }