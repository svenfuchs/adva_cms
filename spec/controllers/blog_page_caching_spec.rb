require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Blog page_caching" do
  include SpecControllerHelper
  
  describe BlogController do
    it "page_caches the :index action" do
      cached_page_filter_for(:index).should_not be_nil
    end
    
    it "tracks read access for a bunch of models for the :index action page caching" do
      BlogController.track_options[:index].should == ['@article', '@articles', '@category', {'@site' => :tag_counts, '@section' => :tag_counts}]
    end
    
    it "page_caches the :show action" do
      cached_page_filter_for(:show).should_not be_nil
    end
    
    it "tracks read access for a bunch of models for the :show action page caching" do
      BlogController.track_options[:show].should == ['@article', '@articles', '@category', {"@section" => :tag_counts, "@site" => :tag_counts}]
    end
    
    it "page_caches the comments action" do
      cached_page_filter_for(:comments).should_not be_nil
    end
    
    it "tracks read access on @commentable for comments action page caching" do
      BlogController.track_options[:comments].should include('@commentable')
    end
  end
end