require File.dirname(__FILE__) + "/../spec_helper"

describe ForumController do
  include SpecControllerHelper
  
  before :each do
    scenario :forum_with_topics
    @site.sections.stub!(:find).and_return @forum
  end
  
  all_paths  = %w( /forums/1 
                   /forums/1/boards/1 )

  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end
  
  all_paths.each do |path|  
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_gets_page_cached
    end
  end
  
  
end