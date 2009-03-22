require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class ForumControllerWithBoardsTest < ActionController::TestCase
  tests ForumController
  
  with_common :is_superuser, :a_forum_with_boards, :a_board_topic, :a_topicless_board
  
  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end
  
  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end
  
  describe "GET to show" do
    action { get :show, default_params }
  
    with :access_granted do
      # it_assigns :boards
      # it_assigns :topics
      it_assigns :topic
      it_renders_template 'forum/show'
      it_caches_the_page :track => ['@topics', '@boards', '@board', '@topic']
    
      it "displays the boards" do
        has_tag 'table[id=boards]' do
          # FIXME doesn't happen
          # has_tag 'tr[id=?]', "board_#{@board.id}"
          # has_tag 'tr[id=?]', "board_#{@another_board.id}"
        end
      end
    
      it "has the links to view boards" do
        has_tag 'a[href=?]', forum_board_path(@section, @board)
        has_tag 'a[href=?]', forum_board_path(@section, @another_board)
      end
    end
  end
  
  describe "GET to show, with board_id" do
    action { get :show, default_params.merge(:board_id => @board.id) }
    
    with :access_granted do
      # it_assigns :boards
      it_assigns :board
      it_assigns :topics
      it_assigns :topic
      it_renders_template 'forum/show'
      it_caches_the_page :track => ['@topics', '@boards', '@board', '@topic']
    end
  end
  
  describe "GET to show, with board_id of a board that has topics" do
    action { get :show, default_params.merge(:board_id => @board.id) }
    
    it "displays the board topics" do
      has_tag 'table[id=topics] tr td[class=topic]'
    end
    
    it "has the link to view topic" do
      has_tag 'a[href=?]', topic_path(@board_topic.section, @board_topic.permalink)
    end
  end
  
  describe "GET to show, with board_id of a board that has no topics" do
    action { get :show, default_params.merge(:board_id => @topicless_board.id) }
    
    it "displays empty list of board topics" do
      has_tag 'p[id=topics][class=empty]'
    end
    
    it "has the link to create a new topic" do
      has_tag 'a[href=?]', new_board_topic_path(@section, @topicless_board)
    end
  end
end