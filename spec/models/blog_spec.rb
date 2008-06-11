require File.dirname(__FILE__) + '/../spec_helper'

describe Blog do
  include Stubby
  
  it "is a kind of Section" do
    Blog.new.should be_kind_of(Section)
  end
  
  it "#articles_by_month returns a hash with months (dates) as keys and articles as values" do
    scenario :six_articles_published_in_three_months
    @blog.articles_by_month.size.should == 3
    @blog.article_counts_by_month.transpose.first.map(&:month).sort.should == [1, 2, 3]
    @blog.articles_by_month.transpose.last.flatten.map(&:class).uniq.should == [Article]
  end
  
  it "#article_counts_by_month returns a hash with months (dates) as keys and article counts as values" do
    scenario :six_articles_published_in_three_months

    @blog.article_counts_by_month.size.should == 3
    @blog.article_counts_by_month.transpose.first.map(&:month).sort.should == [1, 2, 3]
    @blog.article_counts_by_month.transpose.last.sort.should == [1, 2, 3]
  end
  
  it "#archive_months returns an array with the months of published articles" do
    scenario :six_articles_published_in_three_months
    @blog.archive_months.map(&:month).sort.should == [1, 2, 3]
  end
end