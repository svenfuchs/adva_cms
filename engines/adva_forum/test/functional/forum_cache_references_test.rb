require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ForumWithBoardCacheReferencesTest < ActionController::TestCase
  tests ForumController
  
  def setup
    super
    CachedPageReference.delete_all
    
    @forum = Forum.find_by_title 'a forum with boards'
    @board = @forum.boards.first
    @topic = @board.topics.first
    
    @request.host = @forum.site.host
    @old_perform_caching, ActionController::Base.perform_caching = ActionController::Base.perform_caching, true
  end
  
  def teardown
    super
    ActionController::Base.perform_caching = @old_perform_caching
  end
  
  test "forum: list of boards references topics_count and posts_count for forum and boards" do
    get :show, :section_id => @forum.id

    references = CachedPageReference.all.map{ |r| [r.object_id, r.object_type, r.method] }
    assert references.include?([@forum.id, 'Forum', 'topics_count'])
    assert references.include?([@forum.id, 'Forum', 'posts_count'])
    assert references.include?([@board.id, 'Board', 'topics_count'])
    assert references.include?([@board.id, 'Board', 'posts_count'])
  end
  
  test "topic list of a board references the board's topics_count and posts_count as well as each topic's posts_count" do
    get :show, :section_id => @forum.id, :board_id => @board.id
    
    references = CachedPageReference.all.map{ |r| [r.object_id, r.object_type, r.method] }
    assert references.include?([@board.id, 'Board', 'topics_count'])
    assert references.include?([@board.id, 'Board', 'posts_count'])
    assert references.include?([@topic.id, 'Topic', 'posts_count'])
  end
end

class ForumWithoutBoardCacheReferencesTest < ActionController::TestCase
  tests ForumController
  
  def setup
    super
    CachedPageReference.delete_all
    
    @forum = Forum.find_by_title 'a forum without boards'
    @topic = @forum.topics.first
    
    @request.host = @forum.site.host
    @old_perform_caching, ActionController::Base.perform_caching = ActionController::Base.perform_caching, true
  end
  
  def teardown
    super
    ActionController::Base.perform_caching = @old_perform_caching
  end

  test "topic list of a (boardless) forum references the forum's topics_count and posts_count as well as each topic's posts_count" do
    get :show, :section_id => @forum.id
  
    references = CachedPageReference.all.map{ |r| [r.object_id, r.object_type, r.method] }
    assert references.include?([@forum.id, 'Forum', 'topics_count'])
    assert references.include?([@forum.id, 'Forum', 'posts_count'])
    assert references.include?([@topic.id, 'Topic', 'posts_count'])
  end
end