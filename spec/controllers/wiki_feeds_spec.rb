require File.dirname(__FILE__) + "/../spec_helper"

describe WikiController, 'feeds' do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :wiki, :category, :tag, :wikipage
    
    @site.sections.stub!(:find).and_return @wiki
    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true
  end
  
  wikipages_feed_paths = %w( /de/wiki.atom
                             /de/wiki/pages/a-wikipage.atom )
                            
  comments_feed_paths  = %w( /de/wiki/comments.atom
                             /de/wiki/pages/a-wikipage/comments.atom )

  # TODO implement wikipage updates feed
  # wikipages_feed_paths.each do |path|
  #   describe "GET to #{path}" do
  #     act! { request_to :get, path }
  #     it_renders_template 'show', :format => :atom
  #   end
  # end
  
  comments_feed_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_renders_template 'comments/comments', :format => :atom        
      it_gets_page_cached
    end
  end
end  
