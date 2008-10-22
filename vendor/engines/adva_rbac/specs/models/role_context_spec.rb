# require File.dirname(__FILE__) + '/../spec_local_helper'
# 
# describe Rbac::Context, 'dynamic class creation' do
#   it "creates a new class inside the Rbac::Context namespace" do
#     lambda{ Rbac::Context::Section }.should_not raise_error
#   end
# 
#   it "inherits the created RoleContext class from the parent's RoleContext class if a parent is given" do
#     Rbac::Context::Section.superclass.should == Rbac::Context::Site
#   end
# 
#   it "inherits the created RoleContext class from the RoleContext::Base class if no parent is given" do
#     Rbac::Context::Account.superclass.should == Rbac::Context::Base
#   end
# end
# 
# describe Rbac::Context, "#parent", :type => :rbac_context do
#   it "returns the subject's parent's role context instance (given a content)" do
#     @content.role_context.parent.should == @section.role_context
#   end
# 
#   it "returns the subject's parent's role context instance (given a section)" do
#     @section.role_context.parent.should == @site.role_context
#   end
# 
#   it "returns the root context if the subject does not have a parent" do
#     @account.role_context.parent.should == Rbac::Context.root
#   end
# end
# 
# describe Rbac::Context, '.children' do
#   it "returns the child classes of a role context class" do
#     Rbac::Context::Site.children.should == [Rbac::Context::Section]
#   end
# end
# 
# describe Rbac::Context, '.all_children' do
#   it "returns the child classes of a role context class and all child classes of its child classes" do
#     Rbac::Context::Site.all_children.should == [Rbac::Context::Section, Rbac::Context::Content, Rbac::Context::Comment]
#   end
# end
# 
# describe Rbac::Context, '.actions' do
#   it "returns the actions that the context knows about" do
#     Rbac::Context::Site.actions.should == ["manage themes", "manage assets"]
#   end
# end
# 
# describe Rbac::Context,'.all_actions' do
#   it "returns the actions that the context knows about" do
#     actions = ["manage themes", "manage assets", "create article", "update article", "delete article"]
#     Rbac::Context::Site.all_actions.should == actions
#   end
# end
# 
# describe Rbac::Context, '#role_authorizing', :type => :rbac_context do
#   include SpecRolesHelper
#   
#   before :each do
#     define_roles!
#     @author_role    = Rbac::Role.build(:author, :context => @content)
#     @owner_role     = Rbac::Role.build(:owner, :context => @account)
#     @superuser_role = Rbac::Role.build(:superuser)
#   end
#   
#   after :each do
#     Rbac::Role.constants.each do |name|
#       Rbac::Role.send :remove_const, name unless name == "Base"
#     end
#     Rbac::Role::Base.children = []
#   end
#   
#   it "returns the default permissions for a given action (given the root context)" do
#     Rbac::Context.root.role_authorizing(:'create article').should == @superuser_role
#   end
# 
#   describe "with no permissions configured" do
#     it "all child contexts return the default permissions for a given action (given a content)" do
#       @account.role_authorizing(:'create article').should == @superuser_role
#     end
#   
#     it "all child contexts return the default permissions for a given action (given a content)" do
#       @content.role_authorizing(:'create article').should == @superuser_role
#     end
#   end
# 
#   describe "with permissions locally configured in child contexts" do
#     it "all child contexts return the default permissions for a given action (given a content)" do
#       @account.permissions = {:'create article' => :owner}
#       @account.role_authorizing(:'create article').should == @owner_role
#     end
# 
#     it "all child contexts return the default permissions for a given action (given a content)" do
#       @content.permissions = {:'create article' => :author}
#       @content.role_authorizing(:'create article').should == @author_role
#     end
#     
#     it "child context permissions do not affect parent contexts" do
#       @content.permissions = {:'create article' => :author}
#       @section.role_authorizing(:'create article').should == @superuser_role
#     end
#   end
# end
# 
# describe Rbac::Context, "#include?", :type => :rbac_context do
#   describe "a context with one of it's child contexts" do
#     it "returns true for an account when the given context is a content of this account" do
#       @account.role_context.include?(@content.role_context).should be_true
#     end
# 
#     it "returns true for an account when the given context is a section of this account" do
#       @account.role_context.include?(@section.role_context).should be_true
#     end
# 
#     it "returns true for an account when the given context is a site of this account" do
#       @account.role_context.include?(@site.role_context).should be_true
#     end
# 
#     it "returns true for an account when the given context the account itself" do
#       @account.role_context.include?(@account.role_context).should be_true
#     end
#   end
#   
#   describe "a context with one of it's parent contexts" do
#     it "returns false for an account when the given context is the global root context" do
#       @account.role_context.include?(Rbac::Context.root).should be_false
#     end
#   
#     it "returns false for a content when the given context is the content's section" do
#       @content.role_context.include?(@section.role_context).should be_false
#     end
#   
#     it "returns false for a content when the given context is the content's section's site" do
#       @content.role_context.include?(@site.role_context).should be_false
#     end
#   
#     it "returns false for a content when the given context is the content's section's site's account" do
#       @content.role_context.include?(@account.role_context).should be_false
#     end
#   
#     it "returns false for a content when the given context is the global root context" do
#       @content.role_context.include?(Rbac::Context.root).should be_false
#     end
#   end
#   
#   describe "a context with an unrelated context" do
#     it "returns false for a site when the given context is a different site" do
#       @site.role_context.include?(@other_site.role_context).should be_false
#     end
# 
#     it "returns false for a site when the given context is a section from a different site" do
#       @site.role_context.include?(@other_section.role_context).should be_false
#     end
# 
#     it "returns false for a site when the given context is an article from a different site" do
#       @site.role_context.include?(@other_content.role_context).should be_false
#     end
#   end
# end

