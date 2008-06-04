require File.dirname(__FILE__) + "/../spec_helper"

describe SectionsController, 'feeds' do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :article
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