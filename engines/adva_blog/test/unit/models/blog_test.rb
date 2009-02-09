require File.dirname(__FILE__) + '/../../test_helper'

class BlogTest < ActiveSupport::TestCase
  def setup
    super
    # FIXME move to database/populate
    @blog = Blog.first
    Article.delete_all
    1.upto(3) do |month|
      1.upto(month) do |day|
        Article.create :author => User.first, :site => @blog.site, :section => @blog,
                       :title => "Article on day #{day} in month #{month}", :body => 'body',
                       :published_at => Time.zone.local(2008, month, day)
      end
    end
  end
  
  test "is a kind of Section" do
    Section.should === Blog.new
  end

  test "#articles_by_month returns a hash with months (dates) as keys and articles as values" do
    @blog.articles_by_month.size.should == 3
    @blog.article_counts_by_month.transpose.first.map(&:month).sort.should == [1, 2, 3]
    @blog.articles_by_month.to_a.transpose.last.flatten.map(&:class).uniq.should == [Article]
  end

  test '#article_counts_by_month returns a hash with months (dates) as keys and article counts as values' do
    @blog.article_counts_by_month.size.should == 3
    @blog.article_counts_by_month.transpose.first.map(&:month).sort.should == [1, 2, 3]
    @blog.article_counts_by_month.transpose.last.sort.should == [1, 2, 3]
  end

  test '#archive_months returns an array with the months of published articles' do
    @blog.archive_months.map(&:month).sort.should == [1, 2, 3]
  end
end