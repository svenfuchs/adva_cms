# require File.dirname(__FILE__) + '/../spec_helper'
# 
# describe 'Roles: ' do
#   include Stubby
# 
#   before :each do
#     scenario :roles
#   end
# 
#   describe '#has_role?' do
#     describe 'a user' do
#       it "has the role :user" do
#         @user.has_role?(:user).should be_true
#       end
# 
#       # TODO Has not. Error in spec definition or unexpected behaviour?
#       it "has the role :author for another user's content" #do
#       #  @user.has_role?(:author, @content).should be_true
#       #end
# 
#       it "does not have the role :moderator" do
#         @user.has_role?(:moderator, @section).should be_false
#       end
# 
#       it "does not have the role :admin" do
#         @user.has_role?(:admin, @site).should be_false
#       end
# 
#       it "does not have the role :superuser" do
#         @user.has_role?(:superuser).should be_false
#       end
#     end
# 
#     describe 'a content author' do
#       it "has the role :user" do
#         @author.has_role?(:user).should be_true
#       end
# 
#       it 'has the role :author for that content' do
#         @author.has_role?(:author, @content).should be_true
#       end
# 
#       it "does not have the role :moderator" do
#         @author.has_role?(:moderator, @section).should be_false
#       end
# 
#       it "does not have the role :admin" do
#         @author.has_role?(:admin, @site).should be_false
#       end
# 
#       it "does not have the role :superuser" do
#         @author.has_role?(:superuser).should be_false
#       end
#     end
# 
#     describe 'a section moderator' do
#       it "has the role :user" do
#         @moderator.has_role?(:user).should be_true
#       end
# 
#       it "has the role :author for another user's content" do
#         @moderator.has_role?(:author, @content).should be_true
#       end
# 
#       it "has the role :moderator for that section" do
#         @moderator.has_role?(:moderator, @section).should be_true
#       end
# 
#       it "does not have the role :admin" do
#         @moderator.has_role?(:admin, @site).should be_false
#       end
# 
#       it "does not have the role :superuser" do
#         @moderator.has_role?(:superuser).should be_false
#       end
#     end
# 
#     describe 'a site admin' do
#       it "has the role :user" do
#         @admin.has_role?(:user).should be_true
#       end
# 
#       it "has the role :author for another user's content" do
#         @admin.has_role?(:author, @content).should be_true
#       end
# 
#       it "has the role :moderator for sections belonging to that site" do
#         @admin.has_role?(:moderator, @section).should be_true
#       end
# 
#       it "has the role :admin for that site" do
#         @admin.has_role?(:admin, @site).should be_true
#       end
# 
#       it "does not have role :admin for another site" do
#         @admin.has_role?(:admin, @another_site).should be_false
#       end
# 
#       it "does not have role :admin for a non-existent site" do
#         @admin.has_role?(:admin, nil).should be_false
#       end
# 
#       it "does not have the role :superuser" do
#         @admin.has_role?(:superuser).should be_false
#       end
#     end
# 
#     describe 'a superuser' do
#       it "has the role :user" do
#         @superuser.has_role?(:user).should be_true
#       end
# 
#       it "has the role :author for another user's content" do
#         @superuser.has_role?(:author, @content).should be_true
#       end
# 
#       it "has the role :moderator for sections belonging to that site" do
#         @superuser.has_role?(:moderator, @section).should be_true
#       end
# 
#       it "has the role :site for that site" do
#         @superuser.has_role?(:admin, @site).should be_true
#       end
# 
#       it "has the role :superuser" do
#         @superuser.has_role?(:superuser).should be_true
#       end
#     end
#   end
# 
#   describe "#permissions (class method)" do
#     it "inverts passed permissions hash and merges it to default_permissions"
#     it "expands :all to [:show, :create, :update, :destroy]"
#   end
# 
#   describe '#role_authorizing' do
#     describe 'on a site with default_permissions' do
#       it 'returns a superuser role for the :create action' do
#         @site.role_authorizing(:create).should == @superuser_role
#       end
# 
#       it 'returns a superuser role for the :update action' do
#         @site.role_authorizing(:update).should == @admin_role
#       end
# 
#       it 'returns a superuser role for the :destroy action' do
#         @site.role_authorizing(:destroy).should == @superuser_role
#       end
#     end
# 
#     describe 'on a section with default_permissions' do
#       it 'returns an admin role for the :create action' do
#         @section.role_authorizing(:create).should == @admin_role
#       end
# 
#       it 'returns an admin role for the :update action' do
#         @section.role_authorizing(:update).should == @admin_role
#       end
# 
#       it 'returns an admin role for the :destroy action' do
#         @section.role_authorizing(:destroy).should == @admin_role
#       end
#     end
# 
#     describe 'on a forum with roles for topic actions all set to user' do
#       before :each do
#         @section.stub!(:permissions).and_return \
#           :section => { :topic => { :show => :user, :create => :user, :update => :user, :destroy => :user }}
#       end
# 
#       it 'returns a user role for the :create action'
#       it 'returns a user role for the :update action'
#       it 'returns a user role for the :destroy action'
#     end
# 
#     describe 'on a forum with roles for topic actions all set to author' do
#       before :each do
#         @section.stub!(:permissions).and_return \
#           :section => { :topic => { :show => :user, :create => :user, :update => :user, :destroy => :user }}
#       end
# 
#       it 'returns a author role for the :create action' # TODO even though this is quite stupid? maybe.
#       it 'the author role for the :create action has the topic set as context'
#       it 'returns a author role for the :update action'
#       it 'the author role for the :update action has the topic set as context'
#       it 'returns a author role for the :destroy action'
#       it 'the author role for the :create delete has the topic set as context'
#     end
#   end
# 
#   describe '#expand' do
#     it 'called on an author role it returns itself, a moderator, admin and superuser role' do
#       @author_role.expand.should == [@author_role, @moderator_role, @admin_role, @superuser_role]
#     end
# 
#     it 'called on a moderator role it returns itself, an admin and superuser role' do
#       @moderator_role.expand.should == [@moderator_role, @admin_role, @superuser_role]
#     end
# 
#     it 'called on an admin role it returns itself and a superuser role' do
#       @admin_role.expand.should == [@admin_role, @superuser_role]
#     end
#   end
# 
#   { Role::User      => 'You need to be logged in to perform this action.',
#     Role::Author    => 'You need to be the author of this object to perform this action.',
#     Role::Moderator => 'You need to be a moderator to perform this action.',
#     Role::Admin     => 'You need to be an admin to perform this action.',
#     Role::Superuser => 'You need to be a superuser to perform this action.' }.each do |role, message|
# 
#     it "#{Role}#message returns '#{message}'" do
#       role.new.message.should == message
#     end
#   end
# end
