require File.dirname(__FILE__) + "/../spec_helper"

describe TopicsController do
  include SpecControllerHelper
  
  forum_path      = '/forums/1'
  topics_path     = '/forums/1/topics'
  topic_path      = '/forums/1/topics/a-topic'
  new_topic_path  = '/forums/1/topics/new'
  edit_topic_path = '/forums/1/topics/a-topic/edit'

  cached_paths = [topic_path]
  all_paths    = cached_paths + [new_topic_path, edit_topic_path]
  
  before :each do
    stub_scenario :forum_with_topics, :user_logged_in
    @forum.stub!(:boards).and_return []

    @controller.stub!(:forum_path).and_return forum_path # TODO have a helper for this kind of stuff
    @controller.stub!(:topic_path).and_return topic_path    
    @controller.stub!(:current_user).and_return @user
    @controller.stub!(:has_permission?).and_return true # TODO
  end

  it "is a BaseController" do
    controller.should be_kind_of(BaseController)
  end

  describe "routing" do
    with_options :section_id => "1" do |route|
      route.it_maps :get,    topic_path,      :show,    :id => 'a-topic'
      route.it_maps :get,    new_topic_path,  :new
      route.it_maps :get,    edit_topic_path, :edit,    :id => 'a-topic'
      route.it_maps :put,    topic_path,      :update,  :id => 'a-topic'
      route.it_maps :delete, topic_path,      :destroy, :id => 'a-topic'
    end
  end  

  cached_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }    
      it_gets_page_cached
    end
  end
  
  describe "GET to #{topic_path}" do
    act! { request_to :get, topic_path }
    it_assigns :topic
    it_renders_template :show
    # it_guards_permissions :show, :topic # deactivated all :show permissions in the backend
    
    it "instantiates a new post object" do
      Post.should_receive(:new).with(:author => @user)
      act!
    end
  end  
  
  describe "POST to :create" do
    before :each do
      @topic.stub!(:state_changes).and_return([:created])
    end
    
    act! { request_to :post, topics_path, :topic => {} }    
    it_assigns :topic
    it_guards_permissions :create, :topic
    
    it "posts a new topic to forum.topics" do
      @forum.topics.should_receive(:post).and_return @topic
      act!
    end
    
    describe "given valid topic params" do
      it_redirects_to { topic_path }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :topic_created
    end
    
    describe "given invalid topic params" do
      before :each do
        @forum.topics.should_receive(:post).and_return @topic
        @topic.should_receive(:save).and_return false
      end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end    
  end

  describe "GET to #{edit_topic_path}" do
    act! { request_to :get, edit_topic_path }    
    it_assigns :topic
    it_renders_template :edit
    it_guards_permissions :update, :topic
  end
  
  describe "PUT to :update" do
    before :each do
      @topic.stub!(:state_changes).and_return([:updated])
    end
    act! { request_to :put, topic_path, :topic => {} }    
    it_assigns :topic    
    it_guards_permissions :update, :topic
    
    it "updates the topic with the topic params" do
      @topic.should_receive(:save).and_return true
      act!
    end
    
    describe "given valid topic params" do
      it_redirects_to { topic_path }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :topic_updated
    end
    
    describe "given invalid topic params" do
      before :each do 
        @topic.stub!(:save).and_return false 
      end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end
  
  describe "DELETE to :destroy" do
    before :each do
      @topic.stub!(:state_changes).and_return([:deleted])
      request.env["HTTP_REFERER"] = forum_path
    end
    
    act! { request_to :delete, topic_path }    
    it_assigns :topic
    it_guards_permissions :destroy, :topic
    
    it "should try to destroy the topic" do
      @topic.should_receive :destroy
      act!
    end 
    
    describe "when destroy succeeds" do
      it_redirects_to { forum_path }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :topic_deleted
    end
    
    describe "when destroy fails" do
      before :each do @topic.stub!(:destroy).and_return false end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end
  
  describe "guarding permissions" do
    before :each do
      @topic.stub!(:state_changes).and_return([:created])
    end
    act! { request_to :post, topics_path, :topic => { 'title' => 'title', 'body' => 'body', 'locked' => 1, 'sticky' => 1 } }
    
    it "should reject sticky and locked parameter values when user does not have permission to moderate a topic" do
      controller.should_receive(:has_permission?).with(:moderate, :topic).and_return(false)
      act!
      controller.params[:topic].keys.should_not include('locked', 'sticky')
    end
    
    it "should not reject sticky and locked parameter values when user does have permission to moderate a topic" do
      controller.should_receive(:has_permission?).with(:moderate, :topic).and_return(true)
      act!
      controller.params[:topic].keys.should include('locked', 'sticky')
    end
  end
end

describe "TopicsSweeper" do
  include SpecControllerHelper
  include FactoryScenario
    controller_name 'topics'

  before :each do
    Site.delete_all
    factory_scenario :forum_with_topics
    @sweeper = TopicSweeper.instance
  end
  
  it "observes Section, Board, Topic" do
    ActiveRecord::Base.observers.should include(:topic_sweeper)
  end

  it "should expire topics that reference a topic's section" do
    @sweeper.should_receive(:expire_cached_pages_by_section).with(@topic.section)
    @sweeper.after_save(@topic)
  end
  
  it "should expire pages that topic board" do
    @topic.stub!(:owner).and_return(Board.new)
    @sweeper.should_receive(:expire_cached_pages_by_reference).with(@topic.board)
    @sweeper.after_save(@topic)
  end
end
  
describe TopicsController, "page_caching" do
  include SpecControllerHelper

  it "page_caches the show action" do
    cached_page_filter_for(:show).should_not be_nil
  end

  it "tracks read access on @show for show action page caching" do
    TopicsController.track_options[:show].should == ['@topic', '@posts']
  end
end
