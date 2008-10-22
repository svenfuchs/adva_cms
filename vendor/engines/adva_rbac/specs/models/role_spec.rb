# require File.dirname(__FILE__) + '/../spec_local_helper'
# 
# describe Rbac::Role, "#message", :type => :rbac_role do
#   before :each do
#     @message = 'You need to be logged in to perform this action.'
#     Rbac::Role.define :user, :message => @message
#   end
#   
#   it "returns the message defined for the role" do
#     Rbac::Role.build(:user).message.should == @message
#   end
# end
# 
# describe Rbac::Role, "#role_name", :type => :rbac_role do
#   before :each do
#     Rbac::Role.define :user
#   end
#   
#   it "returns the role name as a symbol" do
#     Rbac::Role::User.role_name.should == :user
#   end
# end
# 
# describe Rbac::Role, '.all_children', :type => :rbac_role do
#   include SpecRolesHelper
#   
#   before :each do
#     define_roles!
#   end
#   
#   describe "returns all the roles inheriting from the given role" do
#     it "returns :anonymous, :user, :author, :moderator, :admin, :owner, :superuser classes for :base" do
#       expected = [Rbac::Role::Anonymous, Rbac::Role::User, Rbac::Role::Author, Rbac::Role::Moderator, Rbac::Role::Admin, Rbac::Role::Owner, Rbac::Role::Superuser]
#       Rbac::Role::Base.all_children.should == expected
#     end
# 
#     it "returns :user, :author, :moderator, :admin, :owner, :superuser classes for :anonymous" do
#       expected = [Rbac::Role::User, Rbac::Role::Author, Rbac::Role::Moderator, Rbac::Role::Admin, Rbac::Role::Owner, Rbac::Role::Superuser]
#       Rbac::Role::Anonymous.all_children.should == expected
#     end         
# 
#     it "returns :author, :moderator, :admin, :owner, :superuser classes for :user" do
#       expected = [Rbac::Role::Author, Rbac::Role::Moderator, Rbac::Role::Admin, Rbac::Role::Owner, Rbac::Role::Superuser]
#       Rbac::Role::User.all_children.should == expected
#     end         
# 
#     it "returns :moderator, :admin, :owner, :superuser classes for :author" do
#       expected = [Rbac::Role::Moderator, Rbac::Role::Admin, Rbac::Role::Owner, Rbac::Role::Superuser]
#       Rbac::Role::Author.all_children.should == expected
#     end         
# 
#     it "returns :admin, :owner, :superuser classes for :moderator" do
#       expected = [Rbac::Role::Admin, Rbac::Role::Owner, Rbac::Role::Superuser]
#       Rbac::Role::Moderator.all_children.should == expected
#     end         
# 
#     it "returns :owner, :superuser classes for :admin" do
#       expected = [Rbac::Role::Owner, Rbac::Role::Superuser]
#       Rbac::Role::Admin.all_children.should == expected
#     end         
# 
#     it "returns :superuser classes for :owner" do
#       expected = [Rbac::Role::Superuser]
#       Rbac::Role::Owner.all_children.should == expected
#     end         
# 
#     it "returns no classes for :superuser" do
#       expected = []
#       Rbac::Role::Superuser.all_children.should == expected
#     end
#   end
# end
# 
# describe Rbac::Role, '#expand', :type => :rbac_role do
#   include SpecRolesHelper
#   
#   before :each do
#     define_roles!
#     @anonymous_role = Rbac::Role.build(:anonymous)
#     @user_role      = Rbac::Role.build(:user)
#     @author_role    = Rbac::Role.build(:author, :context => @content)
#     @moderator_role = Rbac::Role.build(:moderator, :context => @section)
#     @admin_role     = Rbac::Role.build(:admin, :context => @site)
#     @owner_role     = Rbac::Role.build(:owner, :context => @account)
#     @superuser_role = Rbac::Role.build(:superuser)
#   end
#   
#   it 'called on an anonymous role it returns itself, an user, an author, a moderator, an admin, an owner and a superuser role' do
#     @anonymous_role.expand(@content).should == [@anonymous_role, @user_role, @author_role, @moderator_role, @admin_role, @owner_role, @superuser_role]
#   end
#   
#   it 'called on an user role it returns itself, an author, a moderator, an admin, an owner and a superuser role' do
#     @user_role.expand(@content).should == [@user_role, @author_role, @moderator_role, @admin_role, @owner_role, @superuser_role]
#   end
#   
#   it 'called on an author role it returns itself, a moderator, an admin, an owner and a superuser role' do
#     @author_role.expand(@content).should == [@author_role, @moderator_role, @admin_role, @owner_role, @superuser_role]
#   end
# 
#   it 'called on a moderator role it returns itself, an admin, an owner and a superuser role' do
#     @moderator_role.expand(@content).should == [@moderator_role, @admin_role, @owner_role, @superuser_role]
#   end
#     
#   it 'called on an admin role it returns itself, an owner role and a superuser role' do
#     @admin_role.expand(@content).should == [@admin_role, @owner_role, @superuser_role]
#   end
# 
#   it 'called on a owner role it returns itself, and a superuser role' do
#     @owner_role.expand(@content).should == [@owner_role, @superuser_role]
#   end
# 
#   it 'called on a superuser role it returns only itself' do
#     @superuser_role.expand(@content).should == [@superuser_role]
#   end
# end