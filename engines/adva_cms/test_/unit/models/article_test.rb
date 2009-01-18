require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ArticleTest < ActiveSupport::TestCase
  with_common :a_blog, :a_published_article
  
  describe 'Article' do
    it "sanitizes the attributes excerpt, excerpt_html, body and body_html" do
      # FIXME implement filter_attributes matcher
      # Article.should filter_attributes(:except => [:excerpt, :excerpt_html, :body, :body_html, :cached_tag_list])
    end
    
    it "sets the position before create" do
      Article.before_create.should include(:set_position)
    end
  end
  
  # CLASS METHODS

  describe "#find_by_permalink" do
    it "adds a with_time_delta scope if more than one argument is passed" do
      expectation do
        mock(Article).with_time_delta('2008', '1', '1')
        Article.find_by_permalink '2008', '1', '1', 'an-article', :include => :author
      end
    end
    
    it "does not add a with_time_delta scope if only one argument is passed" do
      expectation do
        dont_allow(Article).with_time_delta(anything)
        Article.find_by_permalink 'a-permalink'
      end
    end
    
    it "finds a record when the passed date scope matches the article's published date" do
      date = [:year, :month, :day].map {|key| @article.published_at.send(key).to_s }
      @section.articles.find_by_permalink(*date << @article.permalink).should == @article
    end
    
    it "does not find a record when the passed date scope does not match the article's published date" do
      date = [:year, :month, :day].map {|key| @article.published_at.send(key).to_s }
      date[2] = date[2].to_i + 1
      @section.articles.find_by_permalink(*date << @article.permalink).should == nil
    end
    
    it "finds a record when no date scope is passed" do
      Article.find_by_permalink(@article.permalink).should == @article
    end
  end
  
  # INSTANCE METHODS
  
  describe '#full_permalink' do
    it 'returns a hash with the year, month, day and permalink' do
      @article.full_permalink.should == { :year      => @article.published_at.year, 
                                          :month     => @article.published_at.month, 
                                          :day       => @article.published_at.day, 
                                          :permalink => @article.permalink }
    end

    it 'raises an exception when the article does not belong to a Blog' do
      @article.reload
      @article.section = Section.new
      lambda{ @article.full_permalink }.should raise_error
    end
    
    # FIXME not true right now, investigate if we want this at all
    # it 'raises an exception when the article is not published' do
    #   @article.reload
    #   @article.published_at = nil
    #   lambda{ @article.full_permalink }.should raise_error
    # end
  end

  describe "#primary?" do
    it "returns true when the article is its section's primary article" do
      @section.articles.primary.primary?.should == true
    end
  
    it "returns false when the article is not section's primary article" do
      @section.articles.build.primary?.should == false
    end
  end
  
  describe '#has_excerpt?' do
    it 'returns true when the excerpt is not blank' do
      @article.excerpt = 'excerpt'
      @article.has_excerpt?.should == true
    end
  
    it 'returns false when the excerpt is nil' do
      @article.excerpt = nil
      @article.has_excerpt?.should == false
    end
  
    it 'returns false when the excerpt is an empty string' do
      @article.excerpt = ''
      @article.has_excerpt?.should == false
    end
  end
  
  describe '#published_month' do
    it 'returns a time object for the first day of the month the article was published in' do
      @article.published_month.should == Time.local(@article.published_at.year, @article.published_at.month, 1)
    end
  end
  
  describe '#draft?' do
    it 'returns true when the article has not published_at date' do
      @article.published_at = nil
      @article.draft?.should == true
    end
  
    it 'returns false when the article has a published_at date' do
      @article.published_at = 1.days.ago
      @article.draft?.should == false
    end
  end
  
  describe '#accept_comments?' do
    it "accepts comments when comments never expire" do
      # FIXME wtf, srsly. use CONSTANTS instead of integers. that's what they are for.
      @article.comment_age = 0
      @article.published_at = 1.days.ago
      @article.accept_comments?.should == true
    end
  
    it "accepts comments when comments are allowed and not expired" do
      @article.comment_age = 3
      @article.published_at = 1.days.ago
      @article.accept_comments?.should == true
    end
  
    it "does not accept comments when comments are allowed but expired" do
      @article.comment_age = 1
      @article.published_at = 1.days.ago
      @article.accept_comments?.should == false
    end
  
    it "does not accept comments when comments are not allowed" do
      @article.comment_age = -1
      @article.published_at = 1.days.ago
      @article.accept_comments?.should == false
    end
  
    it "does not accept comments when the article is not published" do
      @article.comment_age = 0
      @article.published_at = nil
      @article.accept_comments?.should == false
    end
  end
  
  describe '#published?' do
    it "returns true when published_at equals the current time" do
      @article.published_at = Time.zone.now
      @article.published?.should == true
    end
  
    it "returns true when published_at is a past date" do
      @article.published_at = 1.day.ago
      @article.published?.should == true
    end
  
    it "returns false when published_at is a future date" do
      @article.published_at = 1.day.from_now
      @article.published?.should == false
    end
  
    it "returns false when published_at is nil" do
      @article.published_at = nil
      @article.published?.should == false
    end
  end
  
  describe "#previous" do
    it "finds the previous published article in the article's section" do
      expectation do
        options = {:conditions => ["published_at < ?", @article.published_at], :order=>:published_at}
        mock(Article).find_published(:first, options)
        @article.previous
      end
    end
  end
  
  describe "#next" do
    it "finds the next published article in the article's section" do
      expectation do
        options = {:conditions => ["published_at > ?", @article.published_at], :order=>:published_at}
        mock(Article).find_published(:first, options)
        @article.next
      end
    end
  end
  
  describe "#set_position" do
    it "sorts the article to the bottom of the list (sets to max(position) + 1)" do
      article = @section.articles.create! :title => 'title', :body => 'body', :author => User.first
      article.position.should == @section.articles.maximum(:position).to_i
    end
  end

  describe "filtering" do
    it "it allows using insecure html in article body and excerpt" do
      @article = Article.new :body => 'p{position:absolute; top:50px; left:10px; width:150px; height:150px}. insecure css'
      @article.filter = 'textile_filter'
      @article.save(false)
      @article.body_html.should == %(<p style="position:absolute; top:50px; left:10px; width:150px; height:150px;">insecure css</p>)
    end
  end
end