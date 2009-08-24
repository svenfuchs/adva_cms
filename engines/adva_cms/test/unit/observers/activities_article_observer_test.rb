require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

if Rails.plugin?(:adva_activity)
  class ActivitiesArticleObserverTest < ActiveSupport::TestCase
    def setup
      super
      Article.old_add_observer(@observer = Activities::ArticleObserver.instance)
      @article = Article.first
    end

    def teardown
      super
      Article.delete_observer(@observer)
    end

    test "logs a 'created' activity when the article is a new_record" do
      article = Article.create! :title => 'title', :body => 'body', :author => User.first,
                                :site => Site.first, :section => Section.first
      article.activities.first.actions.should == ['created']
    end

    test "logs a 'revised' activity when the article already exists and was revised" do
      @article.update_attributes! :title => 'title was revised'
      @article.activities.first.actions.should == ['revised']
    end

    test "logs a 'published' activity when the article is now published and :published_at was changed" do
      @article.update_attributes! :published_at => Time.now
      @article.activities.first.actions.should == ['published']
    end

    test "logs an 'unpublished' activity when the article is now a draft and :published_at was changed" do
      @article.update_attributes! :published_at => nil
      @article.activities.first.actions.should == ['unpublished']
    end

    test "logs a 'deleted' activity when the article was destroyed" do
      @article.destroy
      @article.activities.first.actions.should == ['deleted']
    end
  end
end