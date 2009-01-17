require File.expand_path(File.dirname(__FILE__) + "/../test_helper")
  
# TODO
# try stubbing #perform_action for it_guards_permissions
# specify update_all action
# somehow publish passed/failed expectations from RR to test/unit result?
# make --with=access_control,caching options accessible from the console (Test::Unit runner)

# With.aspects << :access_control

class PostsControllerTest < ActionController::TestCase
  tests PostsController
  
  with_common :is_superuser, :a_forum_without_boards, :a_topic_with_reply
  
  def default_params
    { :site_id => @site.id, :section_id => @section.id, :topic_id => @topic.id }
  end
  
  def default_params_with_return
    { :site_id => @site.id, :section_id => @section.id, :topic_id => @topic.id, :return_to => topic_path(@section, @topic) }
  end
  
  test "is a BaseController" do
    BaseController.should === @controller # FIXME matchy doesn't have a be_kind_of matcher
  end
  
  describe "GET to new" do
    action { get :new, default_params }
    
    it_assigns :section, :topic, :post
    
    it "has a create form" do
      has_form_posting_to topic_posts_path do
        has_tag :textarea, :id => 'post_body'
      end
    end
  end
  
  describe "GET to edit" do
    action { get :edit, default_params.merge(:id => @topic.initial_post.id) }
    
    it_assigns :section, :topic, :post
    
    it "has an edit form" do
      has_form_putting_to topic_post_path do
        has_tag :textarea, :id => 'post_body'
      end
    end
  end
  
  describe "DELETE to destroy, with initial post" do
    action { delete :destroy, default_params_with_return.merge(:id => @topic.initial_post.id) }
    
    it_assigns :section, :topic, :post
    it_assigns_flash_cookie :error => :not_nil
    it_redirects_to { topic_path(@section, @topic) }
  end
  
  describe "DELETE to destroy, with the reply" do
    action { delete :destroy, default_params_with_return.merge(:id => @reply.id) }
    
    it_assigns :section, :topic, :post
    it_changes 'Post.count' => -1
    it_assigns_flash_cookie :notice => :not_nil
    it_redirects_to { topic_path(@section, @topic) }
    it_sweeps_page_cache :by_reference => :topic
  end
end