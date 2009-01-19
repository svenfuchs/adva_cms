require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ForumCacheReferencesTest < ActionController::TestCase
  tests ForumController
  
  def setup
    super
    @user = Factory :user
    factory_scenario :site_with_forum
    @request.host = @site.host
    @old_perform_caching, ActionController::Base.perform_caching = ActionController::Base.perform_caching, true
  end
  
  def teardown
    ActionController::Base.perform_caching = @old_perform_caching
  end
  
  test "no cached pages" do
    assert CachedPageReference.all.empty?
  end
  
  test "forum: list of boards references topics_count and comments_count for forum and boards" do
    factory_scenario :board_with_topics

    get :show, :section_id => @forum.id

    references = CachedPageReference.all.map{ |r| [r.object_id, r.object_type, r.method] }
    assert references.include?([@forum.id, 'Forum', 'topics_count'])
    assert references.include?([@forum.id, 'Forum', 'comments_count'])
    assert references.include?([@board.id, 'Board', 'topics_count'])
    assert references.include?([@board.id, 'Board', 'comments_count'])
  end
  
  test "topic list of a board references the board's topics_count and comments_count as well as each topic's comments_count" do
    factory_scenario :board_with_topics

    get :show, :section_id => @forum.id, :board_id => @board.id
    
    references = CachedPageReference.all.map{ |r| [r.object_id, r.object_type, r.method] }
    assert references.include?([@board.id, 'Board', 'topics_count'])
    assert references.include?([@board.id, 'Board', 'comments_count'])
    assert references.include?([@topic.id, 'Topic', 'comments_count'])
  end
  
  test "topic list of a (boardless) forum references the forum's topics_count and comments_count as well as each topic's comments_count" do
    factory_scenario :forum_with_topics
    
    get :show, :section_id => @forum.id

    references = CachedPageReference.all.map{ |r| [r.object_id, r.object_type, r.method] }
    assert references.include?([@forum.id, 'Forum', 'topics_count'])
    assert references.include?([@forum.id, 'Forum', 'comments_count'])
    assert references.include?([@topic.id, 'Topic', 'comments_count'])
  end
end