require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
  
# TODO
# try stubbing #perform_action for it_guards_permissions
# specify update_all action
# somehow publish passed/failed expectations from RR to test/unit result?
# make --with=access_control,caching options accessible from the console (Test::Unit runner)

# With.aspects << :access_control

class ForumControllerWithBoardsTest < ActionController::TestCase
  tests ForumController
  
  with_common :is_superuser, :a_forum_with_boards
  
  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end

  view :show do
    has_tag :table, :id => 'boards'
    has_tag :tr, :id => "board_#{@board.id}"
    has_tag :tr, :id => "board_#{@another_board.id}"
  end
  
  test "is a BaseController" do
    BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
  
  describe "GET to show" do
    action { get :show, default_params }
  
    with :access_granted do
      it_assigns :boards
      it_assigns :topics
      it_assigns :topic
      it_renders_template 'forum/show'
    end
  end
  
  describe "GET to show, with board_id" do
    action { get :show, default_params.merge(:board_id => @board.id) }
  
    with :access_granted do
      it_assigns :boards
      it_assigns :board
      it_assigns :topics
      it_assigns :topic
      it_renders_template 'forum/show'
    end
  end
end