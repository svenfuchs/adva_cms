require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# quite a lot is covered by integration test
class AdminIssuesControllerTest < ActionController::TestCase
  tests Admin::IssuesController
  with_common :site_with_newsletter
  
  test "routing" do
    with_options :path_prefix => "/admin/sites/1/newsletters/1/", :site_id => "1", :newsletter_id => "1" do |r|
      r.it_maps :get,    "issues",        :action => 'index'
      r.it_maps :get,    "issues/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "issues/new",    :action => 'new'
      r.it_maps :post,   "issues",        :action => 'create'
      r.it_maps :get,    "issues/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "issues/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "issues/1",      :action => 'destroy', :id => '1'
    end
  end

  def default_params
    { :site_id => @site.id, :newsletter_id => @newsletter.id }
  end

  describe "GET :index" do
    action { get :index, default_params }
    it_guards_permissions :show, :issue
  end

  describe "GET :edit" do
    action { get :edit, default_params.merge(:id => @issue.id) }
    it_guards_permissions :update, :issue
  end
  
  describe "PUT :update" do
    action { put :update, default_params.merge(:id => @issue.id, :title => "test", :body => "test")}
    it_guards_permissions :update, :issue
  end
  
  describe "GET :new" do
    action { get :new, default_params }
    it_guards_permissions :create, :issue
  end
  
  describe "POST :create" do
    action { post :create, default_params.merge(:title => "test", :body => "test")}
    it_guards_permission :create, :issue
  end

  describe "DELETE :destroy" do
    action { delete :destroy, default_params.merge(:id => @issue.id) }
    it_guards_permission :destroy, :issue
  end
end
