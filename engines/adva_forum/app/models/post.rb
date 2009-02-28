class Post < Comment
  belongs_to :board
  belongs_to :topic

  after_save    :update_commentable
  after_destroy :update_commentable

  def filter
    section.content_filter
  end

  # Calls after_comment_update on the commentable so it has the chance to
  # respond to the event, too, e.g. to update cached attributes and stuff
  # Can we extract this to an observer or similar?
  def update_commentable
    commentable.after_comment_update(self) if commentable && commentable.respond_to?(:after_comment_update)
  end

  # belongs_to :topic, :counter_cache => true
  # attr_accessible :body
  # def self.search(query, options = {})
  #   options[:conditions] ||= [" LOWER(#{Post.table_name}.body) LIKE ?", "%#{query}%"] unless query.blank?
  #   options[:select]     ||= " #{Post.table_name}.*, #{Topic.table_name}.title as topic_title, #{Forum.table_name}.name as forum_name"
  #   options[:joins]      ||= " inner join #{Topic.table_name} on #{Post.table_name}.topic_id = #{Topic.table_name}.id inner join #{Forum.table_name} on #{Topic.table_name}.forum_id = #{Forum.table_name}.id"
  #   options[:order]      ||= " #{Post.table_name}.created_at DESC"
  #   options[:count]      ||= " #{Post.table_name}.id"
  #   pag
end