require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Boards:" do
  include SpecViewHelper

  before :each do
    @boards = stub_boards
    @board = stub_board

    assigns[:site] = @site = stub_site
    assigns[:section] = @section = stub_forum

    set_resource_paths :board, '/admin/sites/1/sections/1/'

    template.stub!(:admin_boards_path).and_return(@collection_path)
    template.stub!(:admin_board_path).and_return(@member_path)
    template.stub!(:new_admin_board_path).and_return @new_member_path
    template.stub!(:edit_admin_board_path).and_return(@edit_member_path)
    template.stub!(:update_all_admin_boards_path).and_return("#{@collection_path}/update_all")

    template.stub!(:link_to_function)
    template.stub!(:image_tag)
    template.stub!(:remote_function)
    template.stub!(:form_for)

    template.stub_render hash_including(:partial => 'board')
  end

  describe "the :index view" do
    before :each do
      assigns[:boards] = @boards
    end

    it "should display a list of boards" do
      render "admin/boards/index"
      response.should have_tag('table[id=?]', 'boards')
    end

    it "should render the board partial with the boards collection" do
      template.stub_render hash_including(:partial => 'board', :collection => @boards)
      render "admin/boards/index"
    end

    it "should render a link to make the boards list sortable depending on the boards count" do
      @boards.should_receive(:size).and_return 5
      render "admin/boards/index"
    end

    it "should render a link to make the boards list sortable when boards count is > 2" do
      @boards.stub!(:size).and_return 3
      template.should_receive(:link_to_function).with('Reorder boards', anything(), anything())
      render "admin/boards/index"
    end
  end

  describe "the :new view" do
    before :each do
      assigns[:board] = @board
    end

    it "should render a form for adding a new board" do
      Board.stub!(:new).and_return @board
      template.should_receive(:form_for).with(:board, @board, :url => @collection_path)
      render "admin/boards/new"
    end
  end

  describe "the :edit view" do
    before :each do
      assigns[:board] = @board
    end

    it "should render a form for editing the board" do
      template.should_receive(:form_for).with(:board, @board, hash_including(:url => @member_path))
      render "admin/boards/edit"
    end
  end

  describe "the board partial" do
    before :each do
      template.stub!(:object).and_return(@board)
    end

    it "should render a link to the board edit view" do
      render "admin/boards/_board"
      response.should have_tag('a[href=?]', @edit_member_path)
    end
  end
end