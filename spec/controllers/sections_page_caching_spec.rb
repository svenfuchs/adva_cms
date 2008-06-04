require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Section page_caching" do
  include SpecControllerHelper
  
  describe SectionsController do
    
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
end