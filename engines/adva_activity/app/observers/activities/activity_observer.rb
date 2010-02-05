module Activities
  class ActivityObserver < ActiveRecord::Observer
    observe :activity

    def after_create(activity)
      self.class.send(:notify_subscribers, activity) if activity.site.email_notification?
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
          subscribers << User.by_role_and_context(:admin, activity.site)
          subscribers << User.by_role_and_context(:superuser, activity.site)
        end.flatten
      end
    end
  end
end