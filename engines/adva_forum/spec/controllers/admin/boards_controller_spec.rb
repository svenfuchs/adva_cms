require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::BoardsController do
  include SpecControllerHelper

  before :each do
    stub_scenario :forum_with_no_topics
    @board = stub_board

    set_resource_paths :board, '/admin/sites/1/sections/1/'

    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true
  end

  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |route|
      route.it_maps :get, "boards", :index
      route.it_maps :get, "boards/1", :show, :id => '1'
      route.it_maps :get, "boards/new", :new
      route.it_maps :post, "boards", :create
      route.it_maps :get, "boards/1/edit", :edit, :id => '1'
      route.it_maps :put, "boards/1", :update, :id => '1'
      route.it_maps :delete, "boards/1", :destroy, :id => '1'
    end
  end

  describe "GET to :index" do
    act! { request_to :get, @collection_path }
    # it_guards_permissions :show, :board
    it_assigns :boards
    it_renders_template :index
  end

  describe "GET to :new" do
    act! { request_to :get, @new_member_path }
    # it_guards_permissions :create, :board
    it_assigns :board
    it_renders_template :new

    it "instantiates a new board from section.boards" do
      @section.boards.should_receive(:build).any_number_of_times.and_return @board
      act!
    end
  end

  describe "POST to :create" do
    act! { request_to :post, @collection_path }
    # it_guards_permissions :create, :board
    it_assigns :board

    it "instantiates a new board from section.boards" do
      @section.boards.should_receive(:build).any_number_of_times.and_return @board
      act!
    end

    describe "given valid board params" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end

    describe "given invalid board params" do
      before :each do @board.stub!(:save).and_return false end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "GET to :edit" do
    act! { request_to :get, @edit_member_path }
    # it_guards_permissions :update, :board
    it_assigns :board
    it_renders_template :edit

    it "fetches a board from section.boards" do
      @section.boards.should_receive(:find).any_number_of_times.and_return @board
      act!
    end
  end

  describe "PUT to :update" do
    act! { request_to :put, @member_path }
    # it_guards_permissions :update, :board
    it_assigns :board

    it "fetches a board from section.boards" do
      @section.boards.should_receive(:find).any_number_of_times.and_return @board
      act!
    end

    it "updates the board with the board params" do
      @board.should_receive(:update_attributes).any_number_of_times.and_return true
      act!
    end

    describe "given valid board params" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end

    describe "given invalid board params" do
      before :each do @board.stub!(:update_attributes).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path }
    # it_guards_permissions :destroy, :board
    it_assigns :board

    it "fetches a board from section.boards" do
      @section.boards.should_receive(:find).any_number_of_times.and_return @board
      act!
    end

    it "should try to destroy the board" do
      @board.should_receive :destroy
      act!
    end

    describe "when destroy succeeds" do
      it_redirects_to { @collection_path }
      it_assigns_flash_cookie :notice => :not_nil
    end

    describe "when destroy fails" do
      before :each do @board.stub!(:destroy).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end

# describe Admin::BoardsController, "page_caching" do
#   include SpecControllerHelper
#
#   it "should activate the BoardSweeper" do
#     Admin::BoardsController.should_receive(:cache_sweeper) do |*args|
#       args.should include(:board_sweeper)
#     end
#     load 'admin/boards_controller.rb'
#   end
#
#   it "should have the BoardSweeper observe Board create, update and destroy events" do
#     Admin::BoardsController.should_receive(:cache_sweeper) do |*args|
#       options = args.extract_options!
#       options[:only].should == [:create, :update, :destroy]
#     end
#     load 'admin/boards_controller.rb'
#   end
# end
#
# describe Admin::BoardsController, "BoardSweeper" do
#   include SpecControllerHelper
#
#   before :each do
#     @board.stub!(:section).and_return stub_section
#     @sweeper = BoardSweeper.instance
#   end
#
#   it "should expire pages that reference an board when an board was saved" do
#     @sweeper.should_receive(:expire_cached_pages_by_section).with(stub_section)
#     @sweeper.after_save(stub_board)
#   end
# end
