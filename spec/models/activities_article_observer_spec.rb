require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/spec_activity_helper'

describe Activities::ArticleObserver do
  include SpecActivityHelper
  include Stubby
  
  it "should log a 'created' activity on save when the article is a new_record" do
    scenario :article_created
    expect_activity_new_with :actions => ['created']
    Article.with_observers('activities/article_observer') { @article.save! }
  end
  
  it "should log a 'revised' activity on save when the article already exists and will save a new version" do
    scenario :article_revised
    expect_activity_new_with :actions => ['revised']
    Article.with_observers('activities/article_observer') { @article.save! }
  end
  
  it "should log a 'published' activity on save when the article is published and the published_at attribute has changed" do
    scenario :article_published
    expect_activity_new_with :actions => ['published']
    Article.with_observers('activities/article_observer') { @article.save! }
  end
  
  it "should log an 'unpublished' activity on save when the article is a draft and the published_at attribute has changed" do
    scenario :article_unpublished
    expect_activity_new_with :actions => ['unpublished']
    Article.with_observers('activities/article_observer') { @article.save! }
  end
  
  it "should log a 'deleted' activity on destroy" do
    scenario :article_destroyed
    expect_activity_new_with :actions => ['deleted']
    Article.with_observers('activities/article_observer') { @article.destroy }
  end
end