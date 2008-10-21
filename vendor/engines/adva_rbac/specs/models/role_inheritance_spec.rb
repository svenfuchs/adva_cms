# require File.dirname(__FILE__) + '/../spec_local_helper'
# 
# describe Rbac::Role, ".define", :type => :rbac_role do
#   it "creates a new Role class in the Rbac::Role namespace" do
#     Rbac::Role.define :admin
#     Rbac::Role.const_defined?('Admin').should be_true
#   end
#   
#   it "inherits the new Role class from Rbac::Role::Base if no parent option is given" do
#     Rbac::Role.define :admin
#     Rbac::Role::Admin.superclass.should == Rbac::Role::Base
#   end
#   
#   it "inherits the new Role class according to the given parent option" do
#     Rbac::Role.define :moderator
#     Rbac::Role.define :admin, :parent => :moderator
#     Rbac::Role::Admin.superclass.should == Rbac::Role::Moderator
#   end
# end
# 
# describe Rbac::Role, ".build", :type => :rbac_role do
#   before :each do
#     Rbac::Role.define :admin
# 
#     @site = Site.new mock('account')
#     @role = Rbac::Role.build :admin, :context => @site
#   end
#   
#   it "instantiates a role with the given type" do
#     @role.should be_instance_of(Rbac::Role::Admin)
#   end
# 
#   it "sets the given context on the instantiated role" do
#     @role.context.should == @site.role_context
#   end
# end
# 
# describe Rbac::Role, "#include?", :type => :rbac_role do
#   before :each do
#     Rbac::Role.define :user
#     Rbac::Role.define :author, :require_context => true, :parent => :user,
#                       :grant => lambda{|context, user| context && !!context.subject.try(:is_author?, user) }
#     Rbac::Role.define :moderator, :parent => :author
#     Rbac::Role.define :admin, :parent => :moderator
#   end
#   
#   it "is true for Author(:context => content).include? User" do
#     @content.stub!(:is_author?).and_return true
#     Rbac::Role.build(:author, :context => @content).should include_role(:user)
#   end
#   
#   it "is true for Admin(:context => site).include? User" do
#     Rbac::Role.build(:admin, :context => @site).should include_role(:user)
#   end
#   
#   it "is true for Moderator(:context => site).include? Moderator(:context => site)" do    
#     Rbac::Role.build(:moderator, :context => @site).should include_role(:moderator, :context => @site)
#   end
#   
#   it "is true for Moderator(:context => site).include? Moderator(:context => site.content)" do    
#     Rbac::Role.build(:moderator, :context => @site).should include_role(:moderator, :context => @content)
#   end
#   
#   it "is true for Admin(:context => site).include? Moderator(:context => site)" do    
#     Rbac::Role.build(:admin, :context => @site).should include_role(:moderator, :context => @site)
#   end
#   
#   it "is true for Admin(:context => site).include? Moderator(:context => site.content)" do    
#     Rbac::Role.build(:admin, :context => @site).should include_role(:moderator, :context => @content)
#   end
#   
#   it "is false for Moderator(:context => site.content).include? Moderator(:context => site)" do    
#     Rbac::Role.build(:moderator, :context => @content).should_not include_role(:moderator, :context => @site)
#   end
#   
#   it "is false for Moderator(:context => site).include? Admin(:context => site)" do    
#     Rbac::Role.build(:moderator, :context => @site).should_not include_role(:admin, :context => @site)
#   end
#   
#   it "is false for Admin(:context => site).include? Admin(:context => other_site)" do    
#     Rbac::Role.build(:admin, :context => @site).should_not include_role(:moderator, :context => @other_site)
#   end
#   
#   it "is false for Admin(:context => site).include? Admin(:context => other_site.content)" do    
#     Rbac::Role.build(:admin, :context => @site).should_not include_role(:moderator, :context => @other_content)
#   end
# end
# 
