require File.dirname(__FILE__) + '/../../spec_helper'

describe "Admin::Boards:" do
  include SpecViewHelper
  
  before :each do
    @boards = stub_boards
    @board = stub_board

    assigns[:site] = @site = stub_site
    assigns[:section] = @section = stub_forum
    @section.stub!(:comments).and_return []
    @section.stub!(:latest_topics).and_return []
    
    set_resource_paths :board, '/admin/sites/1/sections/1/'
    
    template.stub!(:admin_boards_path).and_return(@collection_path)
    template.stub!(:admin_board_path).and_return(@member_path)
    template.stub!(:new_admin_board_path).and_return @new_member_path
    template.stub!(:edit_admin_board_path).and_return(@edit_member_path)
    template.stub!(:update_all_admin_boards_path).and_return("#{@collection_path}/update_all")
    template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:board, @board, template, {}, nil)

    template.stub!(:link_to_function)
    template.stub!(:image_tag)
    template.stub!(:remote_function)
    template.stub!(:confirm_board_delete)
    # template.stub!(:form_for)

    template.stub!(:render).with hash_including(:partial => 'board')
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
      template.should_receive(:render).with hash_including(:partial => 'board', :collection => @boards)
      render "admin/boards/index"
    end

    it "should render the side panel partial" do
      template.should_receive(:render).with hash_including(:partial => 'side_panel')
      render "admin/boards/index"
    end

    it "should render a link to make the boards list sortable depending on the boards count" do
      @boards.should_receive(:size).any_number_of_times.and_return 5
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
    
    it "should render a link to a cancel" do
      render "admin/boards/edit"
      response.should have_tag('a[href=?]', @collection_path)
    end
    
    it "should have the form button for updating the board" do
      render "admin/boards/edit"
      response.should have_tag('input[name=?]', 'commit')
    end
  end

  describe "the :edit view" do
    before :each do
      Site.delete_all
      @site   = Factory :site
      @forum  = Factory :forum, :site => @site
      @board  = Factory :board, :section => @forum
      assigns[:board] = @board
    end

    it "should render a form for editing the board" do
      template.should_receive(:form_for).with(:board, @board, hash_including(:url => @member_path))
      render "admin/boards/edit"
    end
    
    it "should render a link to a cancel" do
      render "admin/boards/edit"
      response.should have_tag('a[href=?]', @collection_path)
    end
    
    it "should have the form button for updating the board" do
      render "admin/boards/edit"
      response.should have_tag('input[name=?]', 'commit')
    end
  end
  
  describe "the form partial" do
    before :each do
      Site.delete_all
      @site   = Factory :site
      @forum  = Factory :forum, :site => @site
      @board  = Factory :board, :section => @forum
      template.stub!(:object).and_return(@board)
    end

    it "should render the side panel partial" do
      template.should_receive(:render).with hash_including(:partial => 'side_panel')
      render "admin/boards/_form"
    end
    
    it "should have the title input label" do
      render "admin/boards/_form"
      response.should have_tag('label[for=?]', 'board_title')
    end
    
    it "should have the title input field" do
      render "admin/boards/_form"
      response.should have_tag('input[name=?]', 'board[title]')
    end
    
    it "should have the description input label" do
      render "admin/boards/_form"
      response.should have_tag('label[for=?]', 'board_description')
    end
    
    it "should have the description textarea field" do
      render "admin/boards/_form"
      response.should have_tag('textarea[name=?]', 'board[description]')
    end
  end

  describe "the board partial" do
    before :each do
      Site.delete_all
      @site   = Factory :site
      @forum  = Factory :forum, :site => @site
      @board  = Factory :board, :section => @forum
      template.stub!(:object).and_return(@board)
    end

    it "should render a link to the board edit view" do
      render "admin/boards/_board"
      response.should have_tag('a[href=?]', @edit_member_path)
    end

    it "should render a link to the board delete action" do
      render "admin/boards/_board"
      response.should have_tag('a.delete')
    end

    it "should render the board description" do
      @board.should_receive(:description).and_return 'description'
      render "admin/boards/_board"
    end

    it "should render the topics count of the board" do
      @board.should_receive(:topics_count).and_return 5
      render "admin/boards/_board"
    end
    
    it "should render the comments count of the board" do
      @board.should_receive(:comments_count).and_return 5
      render "admin/boards/_board"
    end
  end
end