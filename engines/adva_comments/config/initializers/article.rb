ActionController::Dispatcher.to_prepare do
  Article.class_eval do
    has_many_comments :polymorphic => true

    def accept_comments?
      published? && (comment_age > -1) && (comment_age == 0 || comments_expired_at > Time.zone.now)
    end
  end
end