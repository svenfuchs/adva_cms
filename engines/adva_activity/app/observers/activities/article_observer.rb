module Activities
  class ArticleObserver < Activities::Logger
    observe :article

    logs_activity :attributes => [ :title, :type ] do |log|
      log.revised :if => [:save_version?, {:not => :new_record?}]
      log.published :if => [:published_at_changed?, :published?]
      log.unpublished :if => [:published_at_changed?, {:not => :published?}]
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

