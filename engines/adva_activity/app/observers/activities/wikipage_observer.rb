module Activities
  class WikipageObserver < Activities::Logger
    observe :wikipage

    logs_activity :attributes => [:title, :type] do |log|
      log.revised :if => [:save_version?, {:not => :new_record?}]
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

