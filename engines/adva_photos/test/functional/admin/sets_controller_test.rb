require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class SetsControllerTest < ActionController::TestCase
  tests Admin::SetsController
  
  with_common :is_superuser, :a_site_with_album
  
  def default_params
    { :site_id => @site.id, :section_id => @album.id }
  end
  
  def valid_set_params
    { :set => { :title => 'a photo set' } }
  end
  
  def valid_form_params
    default_params.merge(valid_set_params)
  end
  
  def invalid_form_params
    invalid_set_params = valid_set_params
    invalid_set_params[:set][:title] = ''
    default_params.merge(invalid_set_params)
  end
  
  test "should be an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end
  
  describe "routing" do
    with_options :path_prefix => "/admin/sites/1/sections/1/", :site_id => "1", :section_id => "1" do |route|
      route.it_maps :get,     "sets",         :action => 'index'
      route.it_maps :get,     "sets/1",       :action => 'show',    :id => '1'
      route.it_maps :get,     "sets/new",     :action => 'new'
      route.it_maps :post,    "sets",         :action => 'create'
      route.it_maps :get,     "sets/1/edit",  :action => 'edit',    :id => '1'
      route.it_maps :put,     "sets/1",       :action => 'update',  :id => '1'
      route.it_maps :delete,  "sets/1",       :action => 'destroy', :id => '1'
    end
  end
  
  describe "GET to index" do
    action { get :index, default_params }
    
    it_assigns :sets
    it_renders_template :index
    it_does_not_sweep_page_cache
  end
  
  describe "GET to new" do
    action { get :new, default_params }
    
    it_guards_permissions :create, :category
    it_assigns :set => Category
    it_renders_template :new
    it_does_not_sweep_page_cache
    
    # FIXME add view specs for form
  end
  
  describe "POST to create" do
    action { post :create, valid_form_params }
    
    it_guards_permissions :create, :category
    it_assigns :set
    it_redirects_to { admin_sets_path(@site, @album) }
    it_assigns_flash_cookie :notice => :not_nil
    it_sweeps_page_cache :by_section => :section
  end
     
  describe "POST to create, with invalid set params" do
    action { post :create, invalid_form_params }
    
    it_guards_permissions :create, :category
    it_assigns :set
    it_renders_template :new
    it_assigns_flash_cookie :error => :not_nil
    it_does_not_sweep_page_cache
  end
  
  describe "GET to edit" do
    with :a_set do
      action { get :edit, default_params.merge(:id => @set.id) }
    
      it_guards_permissions :update, :category
      it_assigns :set
      it_renders_template :edit
      it_does_not_sweep_page_cache
      
      # FIXME add view specs for form
    end
  end
  
  describe "PUT to update" do
    with :a_set do
      action { put :update, valid_form_params.merge(:id => @set.id) }
    
      it_guards_permissions :update, :category
      it_assigns :set
      it_redirects_to { admin_sets_path(@site, @album) }
      it_assigns_flash_cookie :notice => :not_nil
      it_sweeps_page_cache :by_section => :section
    end
  end
  
  describe "PUT to update, with invalid set params" do
    with :a_set do
      action { put :update, invalid_form_params.merge(:id => @set.id) }
    
      it_guards_permissions :update, :category
      it_assigns :set
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_sweep_page_cache
    end
  end
  
  describe "DELETE to destroy" do
    with :a_set do
      action { delete :destroy, default_params.merge(:id => @set.id) }
    
      it_guards_permissions :destroy, :category
      it_assigns :set
      it_redirects_to { admin_sets_path(@site, @album) }
      it_assigns_flash_cookie :notice => :not_nil
      it_sweeps_page_cache :by_section => :section
    end
  end
end