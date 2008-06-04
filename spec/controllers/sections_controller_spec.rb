require File.dirname(__FILE__) + "/../spec_helper"

describe SectionsController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :article
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