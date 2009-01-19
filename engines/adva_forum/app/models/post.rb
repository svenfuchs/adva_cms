class Post < Comment
  belongs_to :board
  belongs_to :topic

  # belongs_to :topic, :counter_cache => true
  # attr_accessible :body
  # def self.search(query, options = {})
  #   options[:conditions] ||= [" LOWER(#{Post.table_name}.body) LIKE ?", "%#{query}%"] unless query.blank?
  #   options[:select]     ||= " #{Post.table_name}.*, #{Topic.table_name}.title as topic_title, #{Forum.table_name}.name as forum_name"
  #   options[:joins]      ||= " inner join #{Topic.table_name} on #{Post.table_name}.topic_id = #{Topic.table_name}.id inner join #{Forum.table_name} on #{Topic.table_name}.forum_id = #{Forum.table_name}.id"
  #   options[:order]      ||= " #{Post.table_name}.created_at DESC"
  #   options[:count]      ||= " #{Post.table_name}.id"
  #   paginate options
  # end

  # def update_cached_fields
  #   topic.update_cached_post_fields(self)
  # end
  # def topic_is_not_locked
  #   errors.add_to_base("Topic is locked") if topic && topic.locked?
  # end    
end