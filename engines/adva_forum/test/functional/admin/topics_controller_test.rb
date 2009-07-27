require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class Admin::TopicsControllerTest < ActionController::TestCase
  tests Admin::TopicsController

  with_common :is_superuser, :a_forum_without_boards

  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end

  test "should be an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |route|
      route.it_maps :get,     "topics",        :action => 'index'
      route.it_maps :get,     "topics/1",      :action => 'show',     :id => '1'
      route.it_maps :get,     "topics/new",    :action => 'new'
      route.it_maps :post,    "topics",        :action => 'create'
      route.it_maps :get,     "topics/1/edit", :action => 'edit',     :id => '1'
      route.it_maps :put,     "topics/1",      :action => 'update',   :id => '1'
      route.it_maps :delete,  "topics/1",      :action => 'destroy',  :id => '1'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params  }
  
    it_guards_permissions :show, :topic do
      it_assigns :topics
      it_does_not_sweep_page_cache
  
      it_renders :template, :index do
        has_tag 'table[id=topics]'
      end
    end
  end
end