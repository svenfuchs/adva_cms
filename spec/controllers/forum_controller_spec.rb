require File.dirname(__FILE__) + "/../spec_helper"

describe ForumController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :forum
    @site.sections.stub!(:find).and_return @forum
  end
  
  all_paths  = %w( /de/forum )

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