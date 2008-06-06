require File.dirname(__FILE__) + "/../spec_helper"

describe RolesController do
  include Stubby
  include SpecControllerHelper
  
  before :each do
    scenario :site, :user
    @roles_path = '/users/1/roles.json'
  end
  
  describe "GET to :index" do
    act! { request_to :get, @roles_path }
    it_assigns :user, :site
    it_renders_json{ '["site-1-admin","section-1-moderator"]' }
    it_gets_page_cached
  end
end