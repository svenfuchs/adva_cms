require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# quite a lot is covered by integration test
class AdminNewslettersControllerTest < ActionController::TestCase
  tests Admin::NewslettersController
  
  def setup
    super
  end

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
end
