require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/spec_activity_helper'

describe Activities::ArticleObserver do
  include SpecActivityHelper
  include Stubby
  
  before :each do
    scenario :site, :section, :article, :user
    
    # TODO how can I use a mock here? i.e. how can I manually notify the 
    # observers when :save! has been stubbed?
    @article = Article.new :author => @user, :section => @section
    
    methods = { :section_id => @section.id, :site_id => @site.id, :title => 'title',  :type => 'Article' }
    methods.each do |method, result|
      @article.stub!(method).and_return result
    end
  end
  
  it "should log a 'created' activity on save when the article is a new_record" do
    expect_activity_new_with :actions => ['created']
    Article.with_observers('activities/article_observer') { @article.save! }
  end
  
  it "should log a 'revised' activity on save when the article already exists and will save a new version" do
    expect_activity_new_with :actions => ['revised']
    Article.with_observers('activities/article_observer') { revised(@article).save! }
  end
  
  it "should log a 'published' activity on save when the article is published and the published_at attribute has changed" do
    expect_activity_new_with :actions => ['published']
    Article.with_observers('activities/article_observer') { published(@article).save! }
  end
  
  it "should log a 'unpublished' activity on save when the article is a draft and the published_at attribute has changed" do
    expect_activity_new_with :actions => ['unpublished']
    Article.with_observers('activities/article_observer') { unpublished(@article).save! }
  end
  
  it "should log a 'deleted' activity on destroy" do
    expect_activity_new_with :actions => ['deleted']
    Article.with_observers('activities/article_observer') { destroyed(@article).destroy }
  end
end