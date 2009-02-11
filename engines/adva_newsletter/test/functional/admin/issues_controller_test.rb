require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# quite a lot is covered by integration test
class AdminIssuesControllerTest < ActionController::TestCase
  tests Admin::IssuesController
  
  def setup
    super
  end

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
end
