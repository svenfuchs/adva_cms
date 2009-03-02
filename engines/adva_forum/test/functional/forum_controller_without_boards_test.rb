require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class ForumControllerWithoutBoardsTest < ActionController::TestCase
  tests ForumController
  
  with_common :a_forum_without_boards
  
  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end
  
  describe "GET to show" do
    action { get :show, default_params }
    
    it_assigns :boards
    it_assigns :topics
    it_assigns :topic
    it_renders_template 'forum/show'
    it_caches_the_page :track => ['@topics', '@boards', '@board', '@topic']
    
    it "displays the topics" do
      has_tag 'table[id=topics] tr td[class=topic]'
    end
    
    it "has the link to view topic" do
      has_tag 'a[href=?]', topic_path(@section, 'a-topic')
    end
  end
  
  describe "GET to show, without topics" do
    with :without_topics do
      action { get :show, default_params }
    
      it "displays the empty list of topics" do
        has_tag 'p[id=topics][class=empty]'
      end
    
      it "has the link to create a new topic" do
        has_tag 'a[href=?]', new_topic_path(@section)
      end
    end
  end
end