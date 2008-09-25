require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../spec_helpers/spec_activity_helper'

describe Activities::ActivityObserver do
  include SpecActivityHelper
  include Stubby

  describe "for articles" do
    it "sends a notification when a new article is posted" do
      @article = Article.new(:author => stub_user,
                             :site => stub_site,
                             :section => stub_section,
                             :title => 'An article',
                             :body => 'body')

      # TODO: this should really test if the method is being passed an activity
      ActivityNotifier.should_receive(:deliver_new_content_notification)
      Activity.with_observers('activities/activity_observer') do
        Article.with_observers('activities/article_observer') { @article.save! }
      end
    end
  end

  describe "for comments" do
    it "sends a notification when a new comment is posted" do
      @comment = Comment.new(:author => stub_user,
                             :commentable => stub_article,
                             :body => 'body',
                             :section => stub_section,
                             :site => stub_site)


      # wtf? ...
      stub_article.stub!(:[]).with('type').and_return('Article')
      stub_site.stub!(:approved_comments_counter)
      stub_section.stub!(:approved_comments_counter)
      stub_article.stub!(:approved_comments_counter)

      # TODO: this should really test if the method is being passed an activity
      ActivityNotifier.should_receive(:deliver_new_content_notification)
      Activity.with_observers('activities/activity_observer') do
        Comment.with_observers('activities/comment_observer') { @comment.save! }
      end
    end
  end

  describe "for wikipages" do
    it "sends a notification when a new wikipage is posted" do
      @wikipage = Wikipage.new(:author => stub_user,
                               :site => stub_site,
                               :section => stub_section,
                               :title => 'title', :body => 'body')

      # TODO: this should really test if the method is being passed an activity
      ActivityNotifier.should_receive(:deliver_new_content_notification)
      Activity.with_observers('activities/activity_observer') do
        Wikipage.with_observers('activities/wikipage_observer') { @wikipage.save! }
      end
    end
  end
end