require File.dirname(__FILE__) + "/../spec_helper"

describe RolesController do
  include Stubby
  include SpecControllerHelper

  before :each do
    scenario :empty_site, :user_logged_in, :user_is_admin
    User.stub!(:find).and_return @user
  end

  describe "GET to :index" do
    act! { request_to :get, '/users/1/roles.js' }
    it_assigns :user, :site
    it_renders_template :index, :format => :js
    it_gets_page_cached
  end
end