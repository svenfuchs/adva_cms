require File.expand_path(File.dirname(__FILE__) + '/../test_helper.rb')

class TopicsControllerTest < ActionController::TestCase
  tests TopicsController

  with_common :is_user, :a_forum_without_boards, :a_topic_with_reply

  def default_params
    { :section_id => @section.id }
  end

  def valid_topic_params
    { :topic => { :author => @user, :title => 'another topic', :body => 'another topic body',
                  :permalink => 'another-topic' }}
  end

  def valid_form_params
    default_params.merge(valid_topic_params)
  end

  def invalid_form_params
    invalid_form_params = valid_form_params
    invalid_form_params[:topic][:title] = ''
    invalid_form_params
  end

  test "is a BaseController" do
    @controller.should be_kind_of(BaseController)
  end

  describe "routing" do
    with_options :section_id => "1" do |route|
      route.it_maps :get,    '/forums/1/topics/a-topic',      :action => 'show',    :id => 'a-topic'
      route.it_maps :get,    '/forums/1/topics/new',          :action => 'new'
      route.it_maps :get,    '/forums/1/topics/a-topic/edit', :action => 'edit',    :id => 'a-topic'
      route.it_maps :put,    '/forums/1/topics/a-topic',      :action => 'update',  :id => 'a-topic'
      route.it_maps :delete, '/forums/1/topics/a-topic',      :action => 'destroy', :id => 'a-topic'
    end
  end

  describe "GET to show" do
    action { get :show, default_params.merge(:id => @topic.permalink) }

    it_assigns :topic
    it_assigns :post
    it_assigns :posts
    it_renders_template :show
    it_caches_the_page :track => ['@topic', '@posts']
    it_does_not_sweep_page_cache

    # FIXME add view specs (taken from old story)
    # And the page shows 'the topic title'
    # And the page shows 'the initial post body'
  end

  describe "GET to new" do
    action { get :new, default_params }
    it_guards_permissions :create, :topic do
      it_assigns :topic => Topic
      it_renders_template :new
      it_does_not_sweep_page_cache
      it_does_not_cache_the_page
    end
  end

  describe "POST to :create" do
    action { post :create, valid_form_params }

    it_guards_permissions :create, :topic do
      it_assigns :topic => Topic
      it_redirects_to { topic_url(@section, Topic.find_by_permalink('another-topic').permalink) }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :topic_created
      it_sweeps_page_cache :by_section => :section
      it_does_not_cache_the_page
    end
  end

  describe "POST to create, given invalid topic params" do
    action { post :create, invalid_form_params }

    it_guards_permissions :create, :topic do
      it_assigns :topic => Topic
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
      it_does_not_sweep_page_cache
      it_does_not_cache_the_page
    end
  end

  describe "GET to edit" do
    action { get :edit, default_params.merge(:id => @topic.permalink) }

    it_guards_permissions :update, :topic

    with :access_granted do
      it_assigns :topic
      it_renders_template :edit
      it_does_not_sweep_page_cache
      it_does_not_cache_the_page
    end

    # it_guards_permissions :update, :topic do
    #   it_assigns :topic
    #   it_renders_template :edit
    #   it_does_not_sweep_page_cache
    #   it_does_not_cache_the_page
    # end
  end

  describe "PUT to update" do
    action { put :update, valid_form_params.merge(:id => @topic.permalink) }

    it_guards_permissions :update, :topic

    with :access_granted do
      it_assigns :topic
      it_redirects_to { topic_url(@section, Topic.find_by_permalink('another-topic').permalink) }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :topic_updated
      it_sweeps_page_cache :by_section => :section
      it_does_not_cache_the_page
    end

    # it_guards_permissions :update, :topic do
    #   it_assigns :topic
    #   it_redirects_to { topic_url(@section, Topic.find_by_permalink('another-topic').permalink) }
    #   it_assigns_flash_cookie :notice => :not_nil
    #   it_triggers_event :topic_updated
    #   it_sweeps_page_cache :by_section => :section
    #   it_does_not_cache_the_page
    # end
  end

  describe "PUT to update, with invalid topic params" do
    action { put :update, invalid_form_params.merge(:id => @topic.permalink) }

    it_guards_permissions :update, :topic

    with :access_granted do
      it_assigns :topic
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
      it_does_not_sweep_page_cache
      it_does_not_cache_the_page
    end

    # it_guards_permissions :update, :topic do
    #   it_assigns :topic
    #   it_renders_template :edit
    #   it_assigns_flash_cookie :error => :not_nil
    #   it_does_not_trigger_any_event
    #   it_does_not_sweep_page_cache
    #   it_does_not_cache_the_page
    # end
  end

  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.merge(:id => @topic.permalink) }

    it_guards_permissions :destroy, :topic

    with :access_granted do
      it_assigns :topic
      it_redirects_to { forum_url(@section) }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :topic_deleted
      it_sweeps_page_cache :by_section => :section
    end

    # it_guards_permissions :destroy, :topic do
    #   it_assigns :topic
    #   it_redirects_to { forum_url(@section) }
    #   it_assigns_flash_cookie :notice => :not_nil
    #   it_triggers_event :topic_deleted
    #   it_sweeps_page_cache :by_section => :section
    # end
  end
end
