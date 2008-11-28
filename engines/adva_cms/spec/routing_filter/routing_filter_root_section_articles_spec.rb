=begin
return nil
require File.dirname(__FILE__) + '/../spec_helper'
#require File.dirname(__FILE__) + '/../spec_mocks'

describe "Routing Filter::RootSectionArticles" do
  include SpecRoutingHelper
  #include SpecMocks

  describe "#before_recognize_path" do
    describe "given an incoming root article permalink path with no locale (like /an-article)" do
      controller_name 'base'

      before :each do
        @section = mock_section(:articles => mock('articles_proxy', :permalinks => ['an-article']))
        Site.should_receive(:find_by_host).and_return mock_site(@section)
      end

      it "should insert the section path segment to the path when the article belongs to the root section" do
        before_recognize_path(:root_section_articles, '/an-article').should == '/section/an-article'
      end

      it "should not modify the path when the article does not belong to the root section" do
        @section.articles.should_receive(:permalinks).and_return ['another-article']
        before_recognize_path(:root_section_articles, '/an-article').should == '/an-article'
      end
    end

    describe "given an incoming root article permalink path with a locale (like /de/an-article)" do
      controller_name 'base'

      before :each do
        @section = mock_section(:articles => mock('articles_proxy', :permalinks => ['an-article']))
        Site.should_receive(:find_by_host).and_return mock_site(@section)
      end

      it "should insert the section path segment to the path when the article belongs to the root section" do
        before_recognize_path(:root_section_articles, '/de/an-article').should == '/de/section/an-article'
      end

      it "should not modify the path when the article does not belong to the root section" do
        @section.articles.should_receive(:permalinks).and_return ['another-article']
        before_recognize_path(:root_section_articles, '/de/an-article').should == '/de/an-article'
      end
    end
  end
end
=end
