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

    # Rbac::Role.define :owner,
    #                   :require_context => Account,
    #                   :parent => :admin,
    #                   :message => 'You need to be the owner of this account to perform this action.'

    Rbac::Role.define :superuser,
                      :parent => :admin, #:owner,
                      :message => 'You need to be a superuser to perform this action.'
  end

  def include_role(name, options = {})
    role = Rbac::Role.build name, options
    simple_matcher do |given, matcher|
      msg = "the role #{name}" + (options[:context] ? " in the context of #{options[:context]}" : '')
      matcher.description = "includes #{msg}"
      matcher.failure_message = "expected #{given} to include #{msg}"
      matcher.negative_failure_message = "expected #{given} not to include #{msg}"
      given.include? role
    end
  end

  def have_role(name, options = {})
    simple_matcher do |given, matcher|
      msg = "role #{name.inspect}" + (options[:context] ? " in the context of #{options[:context]}" : '')
      matcher.description = "has the #{msg}"
      matcher.failure_message = "expected #{given} to have #{msg}"
      matcher.negative_failure_message = "expected #{given} not to have #{msg}"
      given.has_role? name, options
    end
  end
end

class RbacExampleGroup < Spec::Example::ExampleGroup
  include SpecRolesHelper

  before :each do
    backup_role_classes
    remove_role_classes

    Rbac::Context.permissions = { :'create article' => :superuser }

    #@account = Account.new
    @site = Site.new #:account => @account
    @section = Section.new :site => @site
    @content = Content.new :section => @section

    @site_2 = Site.new #:account => @account
    @section_2 = Section.new :site => @site_2

    #@other_account = Account.new
    @other_site = Site.new #:account => @other_account
    @other_section = Section.new :site => @other_site
    @other_content = Content.new :section => @other_section

    @user = User.new #:account => @account
  end

  after :each do
    remove_role_classes
    restore_role_classes
  end

  module RoleBackup
    mattr_accessor :children, :permissions
  end

  def backup_role_classes
    Rbac::Role.constants.each do |name|
      RoleBackup.const_set name, Rbac::Role.const_get(name) unless name == "Base"
    end
    RoleBackup.children = Rbac::Role::Base.children
    RoleBackup.permissions = Rbac::Context.permissions
  end

  def remove_role_classes
    Rbac::Role.constants.each do |name|
      Rbac::Role.send :remove_const, name unless name == "Base"
    end
    Rbac::Role::Base.children = []
  end

  def restore_role_classes
    RoleBackup.constants.each do |name|
      Rbac::Role.const_set name, RoleBackup.const_get(name)
      RoleBackup.send :remove_const, name
    end
    Rbac::Role::Base.children = RoleBackup.children
    Rbac::Context.permissions = RoleBackup.permissions
  end
end
Spec::Example::ExampleGroupFactory.register(:rbac, RbacExampleGroup)