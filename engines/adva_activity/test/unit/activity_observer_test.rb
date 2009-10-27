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
  
  test "#find_subscribers returns only subscribed users" do
    activity    = Activity.new(:site => @site)
    subscribers = @site.users.find(:all, :include => :roles, :conditions => ['roles.name IN (?)', ['superuser', 'admin']])
    assert_equal subscribers.count, Activities::ActivityObserver.send(:find_subscribers, activity).count
  end

  if Rails.plugin?(:adva_wiki)
    test "receives #notify_subscribers when a Wikipage gets created" do
      mock(Activities::ActivityObserver).notify_subscribers(is_a(Activity))
    
      Activity.with_observers('activities/activity_observer') do
        Wikipage.with_observers('activities/wikipage_observer') do
          Wikipage.create! :title => 'A wikipage', :body => 'body', :author => @user, 
                           :site => @site, :section => @section
        end
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