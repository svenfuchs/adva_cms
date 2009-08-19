if Rails.plugin?(:adva_comments)
  ActionController::Dispatcher.to_prepare do
    Photo.class_eval do
      # has_many_comments :polymorphic => true
      has_many_comments :as => :commentable

      delegate :comment_filter, :to => :site
      delegate :accept_comments?, :to => :section
    end
  end
end