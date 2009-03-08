require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class BlogHelperTest < ActionView::TestCase
  include BlogHelper
  
  def setup
    super
    @blog = Blog.first
    @article = @blog.articles.published(:limit => 1)
    @category = @blog.categories.first
    @tags = ['foo', 'bar']
    @month = Time.local(2008, 1)
  end
  
  describe '#articles_title' do
    it 'returns the title with category if given' do
      articles_title(@category).should == "Articles about a category"
    end
  
    it 'returns the title with tags if given' do
      articles_title(nil, @tags).should == "Articles tagged foo and bar"
    end
  
    it 'returns the title with archive month if given' do
      articles_title(nil, nil, @month).should == "Articles from January 2008"
    end
  
    it 'returns the full collection title if all values are given' do
      articles_title(@category, @tags, @month).should == "Articles from January 2008, about a category, tagged foo and bar"
    end
  
    it 'returns the title wrapped into the format string if given' do
      articles_title(@category, :format => '<h1>%s</h1>').should == "<h1>Articles about a category</h1>"
    end
  end

  describe '#archive_month' do
    it 'returns the archive month if year and month are given' do
      archive_month(:year => 2008, :month => 1).should == Time.local(2008, 1)
    end
  
    it '#archive_month returns the archive month if year is given' do
      archive_month(:year => 2008).should == Time.local(2008)
    end
  
    it '#archive_month returns nil if no year is given' do
      archive_month.should be_nil
    end
  end
end