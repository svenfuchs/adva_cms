require File.dirname(__FILE__) + "/../spec_helper"

describe SectionsController do
  include SpecControllerHelper
  
  before :each do
    scenario :section_with_published_article
  end
  
  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end

  describe "GET to :show" do
    act! { request_to :get, '/' }    
    it_assigns :section, :article
    it_renders_template :show
    it_gets_page_cached
    
    describe "with no article permalink present" do
      it "should find the section's primary article" do
        @section.articles.should_receive(:primary).any_number_of_times.and_return @article
        act!
      end  
    end
    
    describe "with an article permalink present" do
      act! { request_to :get, '/section/articles/an-article' }   
      it "should find the section's primary article" do
        @section.articles.should_receive(:find_published_by_permalink).any_number_of_times.and_return @article
        act!
      end  
    end
  end
end

describe SectionsController, 'feeds' do
  include SpecControllerHelper
  
  before :each do
    scenario :section_with_published_article
  end

  comments_paths = %w( /de/section/comments.atom
                       /de/section/articles/an-article.atom)  
  
  comments_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_renders_template 'comments/comments', :format => :atom
      it_gets_page_cached
    end
  end 
end

describe SectionsController, "page_caching" do
  include SpecControllerHelper
  
  it "page_caches the show action" do
    cached_page_filter_for(:show).should_not be_nil
  end
  
  it "tracks read access on @article for show action page caching" do
    SectionsController.track_options[:show].should include('@article')
  end
  
  it "page_caches the comments action" do
    cached_page_filter_for(:comments).should_not be_nil
  end
  
  it "tracks read access on @commentable for comments action page caching" do
    SectionsController.track_options[:comments].should include('@commentable')
  end
end