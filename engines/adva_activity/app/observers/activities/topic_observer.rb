module Activities
  class TopicObserver < Activities::Logger
    observe :topic

    logs_activity :attributes => [ :title, :sticky, :locked ] do |log|
      log.created   :if => [:created_at_changed?, :new_record?]
      log.edited    :if => [:title_changed?, {:not => :new_record?}]
      log.sticked   :if => [:sticky_changed?, :sticky?]
      log.unsticked :if => [:sticky_changed?, {:not => :sticky?}]
      log.locked    :if => [:locked_changed?, :locked?]
      log.unlocked  :if => [:locked_changed?, {:not => :locked?}]
    end

    def initialize_activity(record)
      returning super do |activity|
        activity.site = record.site
        activity.section = record.section
        activity.author = record.author
      end
    end
  end
end
