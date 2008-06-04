require File.dirname(__FILE__) + '/../spec_helper'

describe Article do
  include Stubby
  
  before :each do
    scenario :site, :section, :category, :user

    @article = Article.new :published_at => Time.now
    @article.stub!(:new_record?).and_return(false)
    @article.stub!(:section).and_return Section.new
    @attributes = {:title => 'An article', :section => @section, :author => stub_user}
  end
  
  it "should generate a permalink from title" do
    article = Article.create! @attributes
    article.permalink.should =~ /an-article/
  end
  
  it "should set the position to max(position) + 1 per section" do
    @section.articles.should_receive(:maximum).and_return 5
    article = Article.create! @attributes
    article.position.should == 6
  end
  
  it "should create a new version when saved" do
    article = Article.create! @attributes
    article.versions.last.should be_instance_of(Content::Version)
  end
  
  it "should assign selected categories after save" do
    article = Article.new @attributes.update(:category_ids => [@category.id])
    article.should_receive :save_categories
    article.save
  end
  
  # TODO spec save_categories
  
  describe "#find_published" do
    it "should find published articles" do
      article = Article.create! @attributes.update(:published_at => 1.hour.ago)
      Article.find_published(:all).should include(article)
    end
  
    it "#find_published should not find unpublished articles" do
      article = Article.create! @attributes
      Article.find_published(:all).should_not include(article)
    end
  end
  
  describe "#find_in_time_delta" do
    it "should find articles in the given time delta" do
      published_at = date = 1.hour.ago
      delta = date.year, date.month, date.day
      article = Article.create! @attributes.update(:published_at => published_at)
      Article.find_in_time_delta(*delta).should include(article)
    end
  
    it "#find_in_time_delta should find articles prior the given time delta" do
      published_at = 1.hour.ago
      date = 2.months.ago
      delta = date.year, date.month, date.day
      article = Article.create! @attributes.update(:published_at => published_at)
      Article.find_in_time_delta(*delta).should_not include(Article.new)
    end
  
    it "#find_in_time_delta should find articles after the given time delta" do
      published_at = 2.month.ago
      date = Time.zone.now
      delta = date.year, date.month, date.day
      article = Article.create! @attributes.update(:published_at => published_at)
      Article.find_in_time_delta(*delta).should_not include(article)
    end
  end
  
  describe "#find_by_permalink" do  
    it "should not apply with_time_delta scope if the given permalink is not an array" do
      Article.should_not_receive :with_time_delta
      Article.find_by_permalink 'a-permalink'
    end
    
    it "should apply with_time_delta scope if the given permalink is an array" do
      Article.should_receive :with_time_delta
      Article.find_by_permalink ['2008', '1', '1', 'a-permalink']
    end
  end
  
  describe "#find_every" do
    it "should not apply the default_find_options (order) if :order option is given" do
      Article.should_receive(:find_by_sql).with(/ORDER BY id/).and_return [@article]
      Article.find :all, :order => :id
    end
    
    it "should apply the default_find_options (order) if :order option is not given" do
      order = /ORDER BY #{Article.default_find_options[:order]}/
      Article.should_receive(:find_by_sql).with(order).and_return [@article]
      Article.find :all
    end

    it "should find articles tagged with :tags if the option :tags is given" do
      Article.should_receive :find_tagged_with
      Article.find :all, :tags => %w(foo bar)
    end
  end
  
  it "#previous finds the previous published article in the article's section" do
    options = {:conditions => ["published_at < ?", @article.published_at], :order=>:published_at}
    Article.should_receive(:find_published).with :first, options
    @article.previous
  end
  
  it "#next finds the next published article in the article's section" do
    options = {:conditions => ["published_at > ?", @article.published_at], :order=>:published_at}
    Article.should_receive(:find_published).with :first, options
    @article.next
  end
  
  it "should accept comments when comments never expire" do
    @article.should_receive(:comment_age).any_number_of_times.and_return(0)
    @article.should_receive(:published_at).any_number_of_times.and_return(2.days.ago)
    @article.accept_comments?.should be_true
  end
  
  it "should accept comments when comments are allowed and not expired" do
    @article.should_receive(:comment_age).any_number_of_times.and_return(3)
    @article.should_receive(:published_at).any_number_of_times.and_return(2.days.ago)
    @article.accept_comments?.should be_true 
  end
  
  it "should not accept comments when comments are allowed but expired" do
    @article.should_receive(:comment_age).any_number_of_times.and_return(2)
    @article.should_receive(:published_at).any_number_of_times.and_return(3.days.ago)
    @article.accept_comments?.should be_false
  end
  
  it "should not accept comments when comments are not allowed" do
    @article.should_receive(:comment_age).any_number_of_times.and_return(-1)
    @article.should_receive(:published_at).any_number_of_times.and_return(2.days.ago)
    @article.accept_comments?.should be_false
  end
  
  it "should not accept comments when the article is not published" do
    @article.should_receive(:published_at).any_number_of_times.and_return(nil)
    @article.accept_comments?.should be_false
  end
  
  it "should be published when published_at equals the current time" do
    @article.should_receive(:published_at).any_number_of_times.and_return(Time.zone.now)
    @article.published?.should be_true
  end
  
  it "should be published when published_at is a past date" do
    @article.should_receive(:published_at).any_number_of_times.and_return(1.day.ago)
    @article.published?.should be_true
  end
  
  it "should not be published when published_at is a future date" do
    @article.should_receive(:published_at).any_number_of_times.and_return(1.day.from_now)
    @article.published?.should be_false
  end
  
  it "should not be published when published_at is nil" do
    @article.should_receive(:published_at).any_number_of_times.and_return(nil)
    @article.published?.should be_false
  end
  
end