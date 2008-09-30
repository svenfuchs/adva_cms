module Activities
  class ActivityObserver < ActiveRecord::Observer
    observe :activity

    def after_create(activity)
      self.class.send(:notify_subscribers, activity)
    end

    private
    class << self
      def notify_subscribers(activity)
        find_subscribers(activity).each do |subscriber|
          ActivityNotifier.deliver_new_content_notification(activity, subscriber)
        end
      end

      def find_subscribers(activity)
        returning [] do |subscribers|
          subscribers << User.find_all_by_site_and_role(activity.site, :admin)
          subscribers << User.find_all_by_site_and_role(activity.site, :superuser)
        end.flatten
      end
    end
  end
end