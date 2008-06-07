require File.dirname(__FILE__) + "/../spec_helper"

describe TopicsController do
  include SpecControllerHelper
  
  forum_path      = '/de/forum'
  topics_path     = '/de/forum/topics'
  topic_path      = '/de/forum/topics/a-topic'
  new_topic_path  = '/de/forum/topics/new'
  edit_topic_path = '/de/forum/topics/a-topic/edit'

  cached_paths = [topic_path]
  all_paths    = cached_paths + [new_topic_path, edit_topic_path]
  
  before :each do
    scenario :site, :section, :forum
    
    @site.sections.stub!(:find).and_return @forum
    @topic.stub!(:new_record).and_return false
    
    @controller.stub!(:forum_path).and_return forum_path
    @controller.stub!(:topic_path).and_return topic_path    
    @controller.stub!(:current_user).and_return stub_user    
    @controller.stub! :guard_permission
  end
  
  it "is a BaseController" do
    controller.should be_kind_of(BaseController)
  end

  describe "routing" do
    with_options :section_id => "1", :locale => 'de' do |route|
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
  end  

  describe "GET to #{edit_topic_path}" do
    act! { request_to :get, edit_topic_path }    
    it_assigns :topic
    it_renders_template :edit
  end
  
  describe "POST to :create" do
    act! { request_to :post, topics_path, :topic => {} }    
    it_assigns :topic
    
    it "posts a new topic to forum.topics" do
      @forum.topics.should_receive(:post).and_return @topic
      act!
    end
    
    describe "given valid topic params" do
      it_redirects_to { topic_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid topic params" do
      before :each do @topic.should_receive(:save).and_return false end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end    
  end
  
  describe "PUT to :update" do
    act! { request_to :put, topic_path, :topic => {} }    
    it_assigns :topic    
    
    it "updates the topic with the topic params" do
      @topic.should_receive(:revise).and_return true
      act!
    end
    
    describe "given valid topic params" do
      it_redirects_to { topic_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid topic params" do
      before :each do @topic.stub!(:revise).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "DELETE to :destroy" do
    act! { request_to :delete, topic_path }    
    it_assigns :topic
    
    it "should try to destroy the topic" do
      @topic.should_receive :destroy
      act!
    end 
    
    describe "when destroy succeeds" do
      it_redirects_to { forum_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "when destroy fails" do
      before :each do @topic.stub!(:destroy).and_return false end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end 

end