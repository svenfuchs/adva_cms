class Account < ActiveRecord::Base
  acts_as_role_context_2
  attr_accessor :permissions
end

class Site < ActiveRecord::Base
  acts_as_role_context_2 :actions => ["manage themes", "manage assets"],
                         :roles => [:admin],
                         :parent => Account

  attr_accessor :account, :permissions

  def initialize(account)
    @account = account
  end
end

class Section < ActiveRecord::Base
  acts_as_role_context_2 :actions => ["create article", "update article", "delete article"],
                         :roles => [:moderator],
                         :parent => Site

  attr_accessor :site, :permissions

  def initialize(site)
    @site = site
  end
end

class Content < ActiveRecord::Base
  acts_as_role_context_2 :roles => [:author],
                         :parent => Section

  attr_accessor :section, :permissions

  def initialize(section)
    @section = section
  end
end

class User < ActiveRecord::Base
  attr_accessor :roles

  def initialize(roles = [])
    @roles = roles
  end

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