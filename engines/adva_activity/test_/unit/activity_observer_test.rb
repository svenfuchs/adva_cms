require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class ActivityTest < ActiveSupport::TestCase
  def setup
    super
    @site = Site.first
    @section = @site.sections.root
    @user = User.first
  end
  
  # FIXME
  # Can't get this to pass ... apparently RR has problems with expecting calls
  # to dynamic methods?
  # 
  # test "notify_subscribers sends emails to all subscribers" do
  #   users = User.all
  #   activity = Activity.new
  #   
  #   stub(Activities::ActivityObserver).find_subscribers(activity).returns(users)
  #   mock(ActivityNotifier).deliver_new_content_notification(anything, anything).times(users.size)
  # 
  #   Activities::ActivityObserver.instance.after_create(activity)
  # end
  
  test "receives #notify_subscribers when an Article gets created" do
    mock(Activities::ActivityObserver).notify_subscribers(is_a(Activity))
    
    Activity.with_observers('activities/activity_observer') do
      Article.with_observers('activities/article_observer') do
        Article.create! :title => 'An article', :body => 'body',
                        :author => @user, :site => @site, :section => @section
      end
    end
  end
  
  test "receives #notify_subscribers when a Wikipage gets created" do
    mock(Activities::ActivityObserver).notify_subscribers(is_a(Activity))
    
    Activity.with_observers('activities/activity_observer') do
      Wikipage.with_observers('activities/wikipage_observer') do
        Wikipage.create! :title => 'A wikipage', :body => 'body', :author => @user, 
                         :site => @site, :section => @section
      end
    end
  end
  
  test "receives #notify_subscribers when a Comment gets created" do
    mock(Activities::ActivityObserver).notify_subscribers(is_a(Activity))
    
    Activity.with_observers('activities/activity_observer') do
      Comment.with_observers('activities/comment_observer') do
        Comment.create! :body => 'body', :author => @user, :commentable => Article.first, 
                        :site => @site, :section => @section
      end
    end
  end
end
# require File.dirname(__FILE__) + '/../spec_helper'
# 
# describe Activities::ActivityObserver do
#   include SpecActivityHelper
#   include Stubby
# 
#   describe "notify subscribers" do
#     before(:each) do
#       @activity = Activity.new
#       @activity.stub!(:site).and_return(stub_site)
#       @activity.stub!(:section).and_return(stub_section)
#     end
# 
#     it "finds all admins of the site and superusers who should be notified" do
#       User.should_receive(:by_context_and_role).with(@activity.site, :admin).and_return([])
#       User.should_receive(:by_context_and_role).with(@activity.site, :superuser).and_return(stub_users)
# 
#       Activities::ActivityObserver.send(:find_subscribers, @activity)
#     end
# 
#     it "finds all subscribers" do
#       Activities::ActivityObserver.should_receive(:find_subscribers).with(@activity).and_return(stub_users)
# 
#       Activities::ActivityObserver.send(:notify_subscribers, @activity)
#     end
# 
#     it "notifies all subscribers" do
#       Activities::ActivityObserver.should_receive(:notify_subscribers).with(@activity)
# 
#       Activities::ActivityObserver.send(:new).after_create(@activity)
#     end
# 
#     it "sends emails to all subscribers" do
#       Activities::ActivityObserver.stub!(:find_subscribers).with(@activity).and_return(stub_users)
#       ActivityNotifier.should_receive(:deliver_new_content_notification).exactly(stub_users.size).times
# 
#       Activities::ActivityObserver.send(:new).after_create(@activity)
#     end
#   end
# 
#   describe "for comments" do
#     it "sends a notification when a new comment is posted" do
#       @comment = Comment.new(:author => stub_user,
#                              :commentable => stub_article,
#                              :body => 'body',
#                              :section => stub_section,
#                              :site => stub_site)
# 
# 
#       # wtf? ...
#       stub_article.stub!(:[]).with('type').and_return('Article')
#       stub_site.stub!(:approved_comments_counter)
#       stub_section.stub!(:approved_comments_counter)
#       stub_article.stub!(:approved_comments_counter)
# 
#       # TODO: this should really test if the method is being passed an activity
#       Activities::ActivityObserver.should_receive(:notify_subscribers)
#       Activity.with_observers('activities/activity_observer') do
#         Comment.with_observers('activities/comment_observer') { @comment.save! }
#       end
#     end
#   end
# 
#   describe "for wikipages" do
#     it "sends a notification when a new wikipage is posted" do
#       Content.delete_all
#       @wikipage = Wikipage.new(:author => stub_user,
#                                :site => stub_site,
#                                :section => stub_section,
#                                :title => 'title', :body => 'body')
# 
#       # TODO: this should really test if the method is being passed an activity
#       Activities::ActivityObserver.should_receive(:notify_subscribers)
#       Activity.with_observers('activities/activity_observer') do
#         Wikipage.with_observers('activities/wikipage_observer') { @wikipage.save! }
#       end
#     end
#   end
# end