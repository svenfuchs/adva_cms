module Activities
  class ActivityObserver < ActiveRecord::Observer
    observe :activity

    def after_create(activity)
      ActivityNotifier.deliver_new_content_notification(activity)
    end
  end
end