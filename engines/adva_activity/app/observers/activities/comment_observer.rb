module Activities
  class CommentObserver < Activities::Logger
    observe :comment

    logs_activity do |log|
      log.edited :if => [:body_changed?, {:not => :new_record?}]
      log.approved :if => [:approved_changed?, :approved?]
      log.unapproved :if => [:approved_changed?, :unapproved?]
    end

    def collect_activity_attributes(record)
      attrs = record.send(:clone_attributes)
      attrs = attrs.slice 'commentable_id', 'body', 'author_name', 'author_email', 'author_url'
      type = record.commentable.has_attribute?('type') ? record.commentable['type'] : record.commentable_type
      attrs.update('commentable_type' => type, 'commentable_title' => record.commentable.title)
    end

    def initialize_activity(record)
      returning super do |activity|
        activity.site = record.commentable.site
        activity.section = record.commentable.section
        activity.author = record.author
      end
    end
  end
end