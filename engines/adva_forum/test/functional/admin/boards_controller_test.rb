require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class BoardsControllerTest < ActionController::TestCase
  tests Admin::BoardsController

  with_common :is_superuser, :a_forum_with_boards

  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end

  def valid_board_params
    { :board => { :title => 'a test board' }}
  end

  def valid_form_params
    default_params.merge(valid_board_params)
  end

  def invalid_form_params
    invalid_form_params = valid_form_params
    invalid_form_params[:board][:title] = ''
    invalid_form_params
  end

  test "should be an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |route|
      route.it_maps :get,     "boards",        :action => 'index'
      route.it_maps :get,     "boards/1",      :action => 'show',     :id => '1'
      route.it_maps :get,     "boards/new",    :action => 'new'
      route.it_maps :post,    "boards",        :action => 'create'
      route.it_maps :get,     "boards/1/edit", :action => 'edit',     :id => '1'
      route.it_maps :put,     "boards/1",      :action => 'update',   :id => '1'
      route.it_maps :delete,  "boards/1",      :action => 'destroy',  :id => '1'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params  }

    it_guards_permissions :show, :board
    it_assigns :boards
    it_renders_template :index
    it_does_not_sweep_page_cache

    # FIXME add necessary view specs
  end

  describe "GET to :new" do
    action { get :new, default_params }

    it_guards_permissions :create, :board
    it_assigns :board => Board
    it_renders_template :new
    it_does_not_sweep_page_cache

    # FIXME add view specs for form
  end

  describe "POST to :create" do
    action { post :create, valid_form_params }

    it_guards_permissions :create, :board
    it_assigns :board => Board
    it_redirects_to { admin_boards_url }
    it_assigns_flash_cookie :notice => :not_nil
    it_sweeps_page_cache :by_section => :section, :by_reference => :board
  end

  describe "POST to :create, with invalid board params" do
    action { post :create, invalid_form_params }

    it_guards_permissions :create, :board
    it_assigns :board => Board
    it_renders_template :new
    it_assigns_flash_cookie :error => :not_nil
    it_does_not_sweep_page_cache
  end

  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @board.id) }

    it_guards_permissions :update, :board
    it_assigns :board
    it_renders_template :edit
    it_does_not_sweep_page_cache

    # FIXME add view specs for form
  end

  describe "PUT to :update" do
    action { put :update, valid_form_params.merge(:id => @board.id) }

    it_guards_permissions :update, :board
    it_assigns :board
    it_redirects_to { admin_boards_url }
    it_assigns_flash_cookie :notice => :not_nil
    it_sweeps_page_cache :by_reference => :board
  end

  describe "PUT to :update, with invalid board params" do
    action { put :update, invalid_form_params.merge(:id => @board.id) }

    it_guards_permissions :update, :board
    it_assigns :board
    it_renders_template :edit
    it_assigns_flash_cookie :error => :not_nil
    it_does_not_sweep_page_cache
  end

  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.merge(:id => @board.id) }

    it_guards_permissions :destroy, :board
    it_assigns :board
    it_redirects_to { admin_boards_url }
    it_assigns_flash_cookie :notice => :not_nil
    it_sweeps_page_cache :by_reference => :board
  end
end