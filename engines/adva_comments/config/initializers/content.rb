ActionController::Dispatcher.to_prepare do
  Content.class_eval do
    # has_many_comments :polymorphic => true
    has_many_comments :as => :commentable

    delegate :comment_filter, :to => :site
    delegate :accept_comments?, :to => :section

    def comments_expired_at
      if comment_age == -1
        9999.years.from_now
      else
        (published_at || Time.zone.now) + comment_age.days
      end
    end
  end
end
