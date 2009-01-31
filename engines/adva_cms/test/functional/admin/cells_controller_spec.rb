# FIXME implement

# require File.dirname(__FILE__) + "/../../spec_helper"
# 
# describe Admin::CellsController do
#   include SpecControllerHelper
# 
#   before(:each) do
#     @controller.stub!(:require_authentication)
#     @controller.stub!(:has_permission?).and_return(true)
#     @controller.stub!(:current_user).and_return(stub_user)
#     User.stub!(:find).and_return(stub_user)
#     #Cells.stub!(:all).and_return([])
#     I18n.stub!(:translate).and_return("") # FIXME: this is so that the build doesn't break
#   end
# 
#   it "should be an Admin::BaseController" do
#     controller.should be_kind_of(Admin::BaseController)
#   end
# 
#   describe "routing" do
#     with_options :path_prefix => '/admin/' do |route|
#       route.it_maps :get, "cells", :index
#     end
#   end
# 
#   describe "GET to :index" do
#     act! { request_to :get, '/admin/cells', :format => 'xml' }
# 
#     it_assigns :cells
#   end
# end
