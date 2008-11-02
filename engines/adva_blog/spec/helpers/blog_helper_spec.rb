require File.dirname(__FILE__) + '/../spec_helper'

describe BlogHelper do
  include Stubby, UrlMatchers, BlogHelper

  before(:each) do
    stub_scenario :blog_with_published_article
  end

  describe '#collection_title' do
    before(:each) do
      @category.stub!(:title).and_return('Category Title')
      @tags = ['Tag 1', 'Tag 2']
    end

    it "shows the full collection title if all parameters are given" do
      helper.stub!(:archive_month).and_return(Time.local(2008, 9))
      helper.collection_title(@category, @tags).should == "Articles from September 2008, about Category Title, tagged Tag 1 and Tag 2"
    end

    it "shows the collection title with archive month if only archive month is given" do
      helper.stub!(:archive_month).and_return(Time.local(2008, 9))
      helper.collection_title(nil, nil).should == "Articles from September 2008"
    end

    it "shows the collection title with category title if only category is given" do
      helper.stub!(:archive_month).and_return(nil)
      helper.collection_title(@category, nil).should == "Articles about Category Title"
    end

    it "shows the collection title with tags if only tags are given" do
      helper.stub!(:archive_month).and_return(nil)
      helper.collection_title(nil, @tags).should == "Articles tagged Tag 1 and Tag 2"
    end
  end

  describe "#archive_month" do
    before(:each) do
      @params = {}
      helper.stub!(:params).and_return(@params)
    end

    it "returns the archive month if year and month are given" do
      @params.stub!(:[]).with(:year).and_return(2008)
      @params.stub!(:[]).with(:month).and_return(9)
      helper.archive_month.should == Time.local(2008, 9)
    end

    it "returns the archive month if year is given" do
      @params.stub!(:[]).with(:year).and_return(2008)
      @params.stub!(:[]).with(:month).and_return(nil)
      helper.archive_month.should == Time.local(2008)
    end

    it "does not return the archive month if no year is given" do
      params.stub!(:[]).with(:year).and_return(nil)
      helper.archive_month.should be_nil
    end
  end
end