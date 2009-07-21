require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class RolesControllerTest < ActionController::TestCase
  with_common :a_site, :a_user

  test "is an BaseController" do
    @controller.should be_kind_of(BaseController)
  end

  describe "GET to :index" do
    action { get :index, { :user_id => @user.id } }
    
    it_assigns :site, :user, :roles
    it_renders_template :index, :format => :js
    it_caches_the_page # FIXME should track user references, eh?
    
    it "always includes the user role" do
      assigns(:roles).map(&:name).should include('user')
    end
  end
end