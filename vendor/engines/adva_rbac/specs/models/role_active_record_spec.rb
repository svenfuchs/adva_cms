# require File.dirname(__FILE__) + '/../spec_local_helper'
# 
# describe Rbac::Role::Base, :type => :rbac_role do
#   include SpecRolesHelper
#   
#   before :each do
#     define_roles!
#   end
#   
#   it "can save to the database" do
#     Rbac::Role.build(:admin, :context => @site).save.should be_true
#   end
#   
#   it "can load from the database" do
#     Rbac::Role::Base.delete_all
#     Rbac::Role::User.create :context => @site
#     Rbac::Role::User.first.should be_instance_of(Rbac::Role::User)
#   end
# end