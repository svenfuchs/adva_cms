class Post < Comment
  alias :topic  :commentable
  alias :topic= :commentable=

  belongs_to :board

  after_save    :update_caches
  after_destroy :update_caches

  def filter
    section.content_filter
  end

  def previous
    topic.posts.find :last, :conditions => ['id < ?', id]
  end
  
  def page
    topic.page(self)
  end

  # Calls after_post_update on the topic so it has the chance to
  # respond to the event, too, e.g. to update cached attributes and stuff
  # Can we extract this to an Observer or something?
  def update_caches
    topic.after_post_update(self)
  end

  # belongs_to :topic, :counter_cache => true
  # attr_accessible :body
  # def self.search(query, options = {})
  #   options[:conditions] ||= [" LOWER(#{Post.table_name}.body) LIKE ?", "%#{query}%"] if query.present?
  #   options[:select]     ||= " #{Post.table_name}.*, #{Topic.table_name}.title as topic_title, #{Forum.table_name}.name as forum_name"
  #   options[:joins]      ||= " inner join #{Topic.table_name} on #{Post.table_name}.topic_id = #{Topic.table_name}.id inner join #{Forum.table_name} on #{Topic.table_name}.forum_id = #{Forum.table_name}.id"
  #   options[:order]      ||= " #{Post.table_name}.created_at DESC"
  #   options[:count]      ||= " #{Post.table_name}.id"
  #   pag
end