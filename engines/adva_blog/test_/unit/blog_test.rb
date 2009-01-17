require File.dirname(__FILE__) + '/../test_helper'

class BlogTest < ActiveSupport::TestCase
  setup :six_articles_published_in_three_months
  
  test "is a kind of Section" do
    Section.should === Blog.new
  end

  describe '#articles_by_month' do
    it "returns a hash with months (dates) as keys and articles as values" do
      @blog.articles_by_month.size.should == 3
      @blog.article_counts_by_month.transpose.first.map(&:month).sort.should == [1, 2, 3]
      @blog.articles_by_month.transpose.last.flatten.map(&:class).uniq.should == [Article]
    end
  end
  
  describe '#article_counts_by_month' do
    it 'returns a hash with months (dates) as keys and article counts as values' do
      @blog.article_counts_by_month.size.should == 3
      @blog.article_counts_by_month.transpose.first.map(&:month).sort.should == [1, 2, 3]
      @blog.article_counts_by_month.transpose.last.sort.should == [1, 2, 3]
    end
  end
  
  describe '#archive_months' do
    it 'returns an array with the months of published articles' do
      @blog.archive_months.map(&:month).sort.should == [1, 2, 3]
    end
  end
  
  # FIXME move to database/populate
  def six_articles_published_in_three_months
    @blog = Blog.first
    
    Article.delete_all
    1.upto(3) do |month|
      1.upto(month) do |day|
        Article.create :author => User.first, :site => Site.first, :section => @blog,
                       :title => "Article on day #{day} in month #{month}", :body => 'body',
                       :published_at => Time.zone.local(2008, month, day)
      end
    end
  end
end