require File.dirname(__FILE__) + "/../spec_helper"

describe RolesController do
  include Stubby
  include SpecControllerHelper
  
  before :each do
    @site = stub_model Site, :id => 1
    @section = stub_model Section, :id => 1, :site => @site
    @user = stub_model User, :id => 1, :registered? => true, :roles => []
    
    @roles_path = '/users/1/roles.js'
    
    @admin_role     = Role.build :admin, @site
    @moderator_role = Role.build :moderator, @section
    
    controller.stub!(:current_user).and_return @user
    controller.stub!(:page_cache_directory)
    controller.stub!(:save_cache_references)
    @user.roles.stub!(:by_context).and_return [@admin_role, @moderator_role]

    Site.stub!(:find_or_initialize_by_host).and_return @site
  end
  
  describe "GET to :index" do
    act! { request_to :get, @roles_path }
    it_assigns :user, :site
    it_renders_template :index, :format => :js
    # it_gets_page_cached
  end
end