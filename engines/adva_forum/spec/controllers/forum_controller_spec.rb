require File.dirname(__FILE__) + "/../spec_helper"

describe ForumController do
  include SpecControllerHelper
  include FactoryScenario
  
  before :each do
    Site.delete_all
    factory_scenario :forum_with_topics
    
    controller.stub!(:current_user).and_return @user
    
    Site.stub!(:find).and_return @site
    @site.sections.stub!(:find).and_return @forum
  end

  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end
  
  describe "GET to show" do
    before :each do
      @topic = Topic.new(:section => @section, :board => nil, :author => @user)
    end

    describe "topics without boards" do
      act! { request_to :get, "/forums/#{@forum.id}" }
      it_assigns :topics
      it_gets_page_cached
      
      it "instantiates a new topic object" do
        Topic.should_receive(:new).and_return @topic
        act!
      end
    end
    
    describe "topics with boards" do
      before :each do
        @board = Factory :board, :section => @forum, :site => @site
      end
      act! { request_to :get, "/forums/#{@forum.id}" }
      it_assigns :boards
      it_assigns :topics
      it_gets_page_cached
      
      it "instantiates a new topic object" do
        Topic.should_receive(:new).and_return @topic
        act!
      end
    end   
    
    describe "topics with boards, show single board" do
      before :each do
        @board = Factory :board, :section => @forum, :site => @site
      end
      act! { request_to :get, "/forums/#{@forum.id}/boards/#{@board.id}" }
      it_assigns :board
      it_assigns :topics
      it_gets_page_cached
      
      it "instantiates a new topic object" do
        Topic.should_receive(:new).and_return @topic
        act!
      end
    end
  end
end
