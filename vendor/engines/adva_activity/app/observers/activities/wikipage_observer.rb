module Activities
  class WikipageObserver < Activities::Logger
    observe :wikipage
  
    logs_activity :attributes => [:title, :type] do |log|
      log.revised :if => [:save_version?, {:not => :new_record?}]
    end
    
    def initialize_activity(record)
      returning super do |activity|
        activity.site_id = record.site_id
        activity.section_id = record.section_id
        activity.author = record.author
      end
    end
  end
end

