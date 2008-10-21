# require File.dirname(__FILE__) + '/../spec_local_helper'
#
# class Account < ActiveRecord::Base
#   acts_as_role_context_2
#   attr_accessor :permissions
# end
#
# class Site < ActiveRecord::Base
#   acts_as_role_context_2 :actions => ["manage themes", "manage assets"],
#                          :roles => [:admin],
#                          :parent => Account
#
#   attr_accessor :account, :permissions
#
#   def initialize(account)
#     @account = account
#   end
# end
#
# class Section < ActiveRecord::Base
#   acts_as_role_context_2 :actions => ["create article", "update article", "delete article"],
#                          :roles => [:moderator],
#                          :parent => Site
#
#   attr_accessor :site, :permissions
#
#   def initialize(site)
#     @site = site
#   end
# end
#
# class Content < ActiveRecord::Base
#   acts_as_role_context_2 :roles => [:author],
#                          :parent => Section
#
#   attr_accessor :section, :permissions
#
#   def initialize(section)
#     @section = section
#   end
# end
#
# Rbac::Context.permissions = { :'create article' => :superuser }
#
# class RbacExampleGroup < Spec::Example::ExampleGroup
#   before :each do
#     @account = Account.new
#     @site = Site.new @account
#     @section = Section.new @site
#     @content = Content.new @section
#   end
# end
# Spec::Example::ExampleGroupFactory.register(:rbac, RbacExampleGroup)
#
# # describe Rbac::Context, 'dynamic class creation' do
# #   it "creates a new class inside the Rbac::Context namespace" do
# #     lambda{ Rbac::Context::Section }.should_not raise_error
# #   end
# #
# #   it "inherits the created RoleContext class from the parent's RoleContext class if a parent is given" do
# #     Rbac::Context::Section.superclass.should == Rbac::Context::Site
# #   end
# #
# #   it "inherits the created RoleContext class from the RoleContext::Base class if no parent is given" do
# #     Rbac::Context::Account.superclass.should == Rbac::Context::Base
# #   end
# # end
# #
# # describe Rbac::Context, "#parent", :type => :rbac do
# #   it "returns the subject's parent's role context instance (given a content)" do
# #     @content.role_context.parent.should == @section.role_context
# #   end
# #
# #   it "returns the subject's parent's role context instance (given a section)" do
# #     @section.role_context.parent.should == @site.role_context
# #   end
# #
# #   it "returns the root context if the subject does not have a parent" do
# #     @account.role_context.parent.should == Rbac::Context.root
# #   end
# # end
# #
# # describe Rbac::Context, '.children' do
# #   it "returns the child classes of a role context class" do
# #     Rbac::Context::Site.children.should == [Rbac::Context::Section]
# #   end
# # end
# #
# # describe Rbac::Context, '.all_children' do
# #   it "returns the child classes of a role context class and all child classes of its child classes" do
# #     Rbac::Context::Site.all_children.should == [Rbac::Context::Section, Rbac::Context::Content]
# #   end
# # end
# #
# # describe Rbac::Context, '.actions' do
# #   it "returns the actions that the context knows about" do
# #     Rbac::Context::Site.actions.should == ["manage themes", "manage assets"]
# #   end
# # end
# #
# # describe Rbac::Context,'.all_actions' do
# #   it "returns the actions that the context knows about" do
# #     actions = ["manage themes", "manage assets", "create article", "update article", "delete article"]
# #     Rbac::Context::Site.all_actions.should == actions
# #   end
# # end
#
# describe Rbac::Context, '#role_authorizing', :type => RbacExampleGroup do
#   it "returns the default permissions for a given action (given the root context)" do
#     Rbac::Context.root.role_authorizing(:'create article').should == :superuser
#   end
#
#   describe "with no permissions configured" do
#     it "all child contexts return the default permissions for a given action (given a content)" do
#       @account.role_authorizing(:'create article').should == :superuser
#     end
#
#     it "all child contexts return the default permissions for a given action (given a content)" do
#       @content.role_authorizing(:'create article').should == :superuser
#     end
#   end
#
#   describe "with permissions locally configured in child contexts" do
#     it "all child contexts return the default permissions for a given action (given a content)" do
#       @account.permissions = {:'create article' => :owner}
#       @account.role_authorizing(:'create article').should == :owner
#     end
#
#     it "all child contexts return the default permissions for a given action (given a content)" do
#       @content.permissions = {:'create article' => :author}
#       @content.role_authorizing(:'create article').should == :author
#     end
#
#     it "child context permissions do not affect parent contexts" do
#       @content.permissions = {:'create article' => :author}
#       @section.role_authorizing(:'create article').should == :superuser
#     end
#   end
# end
