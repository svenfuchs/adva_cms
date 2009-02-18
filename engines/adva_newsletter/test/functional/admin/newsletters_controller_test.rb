require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# quite a lot is covered also by integration test
class AdminNewslettersControllerTest < ActionController::TestCase
  tests Admin::NewslettersController
  with_common :site_with_newsletter

  test "routing" do
    with_options :path_prefix => "/admin/sites/1/", :site_id => "1" do |r|
      r.it_maps :get,    "newsletters",        :action => 'index'
      r.it_maps :get,    "newsletters/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "newsletters/new",    :action => 'new'
      r.it_maps :post,   "newsletters",        :action => 'create'
      r.it_maps :get,    "newsletters/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "newsletters/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "newsletters/1",      :action => 'destroy', :id => '1'
    end
  end

  def default_params
    { :site_id => @site.id }
  end

  describe "GET :index" do
    action { get :index, default_params }
    it_guards_permissions :show, :newsletter
  end

  describe "GET :edit" do
    action { get :edit, default_params.merge(:id => @newsletter.id) }
    it_guards_permissions :update, :newsletter
  end
  
  describe "PUT :update" do
    action { put :update, default_params.merge(:id => @newsletter.id, :title => "test", :desc => "test")}
    it_guards_permissions :update, :newsletter
  end
  
  describe "GET :new" do
    action { get :new, default_params }
    it_guards_permissions :create, :newsletter
  end
  
  describe "POST :create" do
    action { post :create, default_params.merge(:title => "test", :desc => "test")}
    it_guards_permission :create, :newsletter
  end

  describe "DELETE :destroy" do
    action { delete :destroy, default_params.merge(:id => @newsletter.id) }
    it_guards_permission :destroy, :newsletter
  end
end
