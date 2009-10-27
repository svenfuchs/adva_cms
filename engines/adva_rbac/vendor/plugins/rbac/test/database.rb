require File.expand_path(File.dirname(__FILE__) + "/test_helper")

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection(config['test'])

ActiveRecord::Base.connection.create_table :users do |t|
  t.string :name
  t.boolean :anonymous
end

ActiveRecord::Base.connection.create_table :sites do |t|
  t.string  :name
end

ActiveRecord::Base.connection.create_table :sections do |t|
  t.string :title
  t.text :permissions
  t.references  :site
end

ActiveRecord::Base.connection.create_table :contents do |t|
  t.references :section
  t.references :author
  t.string :title
  t.text :permissions
end

ActiveRecord::Base.connection.create_table :roles do |t|
  t.references :subject, :polymorphic => true
  t.references :context, :polymorphic => true
  t.string :name
end

ActiveRecord::Base.connection.create_table :groups do |t|
  t.string :name
end

ActiveRecord::Base.connection.create_table :group_memberships do |t|
  t.references :user
  t.references :group
end

ActiveRecord::Base.connection.create_table :role_types do |t|
  t.string :name
  t.boolean :requires_context, :default => true
end

ActiveRecord::Base.connection.create_table :role_type_relationships do |t|
  t.references :master
  t.references :minion
end

class User < ActiveRecord::Base
  class RoleSubject < Rbac::Subject::Base
    def roles
      (object.roles + object.groups.map(&:roles).flatten).uniq # should obviously happen in a single query
    end
  end

  acts_as_role_subject
  has_many :roles, :as => :subject, :class_name => 'Rbac::Role'
  has_many :group_memberships
  has_many :groups, :through => :group_memberships

  def registered?
    !new_record? && !anonymous?
  end
end

class GroupMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
end

class Group < ActiveRecord::Base
  acts_as_role_subject

  has_many :group_memberships
  has_many :members, :through => :group_memberships, :source => :user, :class_name => 'User'
  has_many :roles, :as => :subject, :class_name => 'Rbac::Role'
end

class Site < ActiveRecord::Base
  acts_as_role_context
end

class Section < ActiveRecord::Base
  acts_as_role_context

  belongs_to :site

  def include?(other)
    !!other
  end
end

class Content < ActiveRecord::Base
  acts_as_role_context :parent => :owner

  belongs_to :section
  belongs_to :author, :class_name => 'User'

  def owner
    section
  end

  def include?(other)
    false
  end
end


RoleType = Rbac::RoleType::ActiveRecord::RoleType

site         = Site.create!(:name => 'a site')
another_site = Site.create!(:name => 'another site')

anonymous_type = RoleType.create!(:name => 'anonymous', :requires_context => false)
user_type      = RoleType.create!(:name => 'user',      :requires_context => false, :minions => [anonymous_type])
author_type    = RoleType.create!(:name => 'author',    :requires_context => true , :minions => [user_type])
moderator_type = RoleType.create!(:name => 'moderator', :requires_context => true , :minions => [author_type])
editor_type    = RoleType.create!(:name => 'editor',    :requires_context => true , :minions => [user_type])
superuser_type = RoleType.create!(:name => 'superuser', :requires_context => false, :minions => [moderator_type, editor_type])
pizzaboy_type  = RoleType.create!(:name => 'pizzaboy',  :requires_context => true)

superuser         = User.create!(:name => 'superuser')
admin             = User.create!(:name => 'site admin')
editor            = User.create!(:name => 'editor')
moderator         = User.create!(:name => 'moderator')
site_moderator    = User.create!(:name => 'site moderator')
author            = User.create!(:name => 'author')
user              = User.create!(:name => 'user')
anonymous         = User.create!(:name => 'anonymous', :anonymous => true)
site_designer     = User.create!(:name => 'designer')

blog           = Section.create!(:title => 'blog', :site => site)
content        = Content.create!(:title => 'content', :section => blog, :author => author)

john  = User.create!(:name => 'john')
paul  = User.create!(:name => 'paul')
mick  = User.create!(:name => 'mick')
keith = User.create!(:name => 'keith')

beatles = Group.create!(:name => 'beatles', :members => [john, paul])
stones  = Group.create!(:name => 'stones', :members => [mick, keith])

beatles.roles.create!(:name => 'superuser')
stones.roles.create!(:name => 'pizzaboy')
editor.roles.create!(:name => 'editor')
superuser.roles.create!(:name => 'superuser')
admin.roles.create!(:name => 'admin', :context => site)
moderator.roles.create!(:name => 'moderator', :context => blog)
author.roles.create!(:name => 'author', :context => site)
site_moderator.roles.create!(:name => 'moderator', :context => site)
site_designer.roles.create!(:name => 'designer', :context => site)
