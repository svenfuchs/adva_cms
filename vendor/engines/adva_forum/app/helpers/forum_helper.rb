module ForumHelper
  def link_to_topic(*args)
    options = args.extract_options!
    topic = args.pop
    text = args.pop || topic.title
    link_to text, topic_path(topic.section, topic.permalink)    
  end
  
  def link_to_last_post(*args)
    options = args.extract_options!
    topic = args.pop
    text = args.pop || topic.last_comment.created_at.strftime('%d.%m.%y %H:%M')
    options[:anchor] = dom_id(topic.last_comment)
    options[:page] = topic.last_page if topic.last_page > 1
    link_to text, topic_path(topic.section, topic.permalink, options)
  end
  
  def links_to_prev_next_topics(topic, options = {})
    separator = options.delete(:separator) || ' '
    format = options.delete(:format) || '%s'
    links = [link_to_prev_topic(options[:prev], topic), link_to_next_topic(options[:next], topic)]
    format % links.compact.join(separator)
  end
  
  def link_to_prev_topic(*args)
    options = args.extract_options!
    format = options.delete(:format) || '%s'
    topic = args.pop
    text = args.pop || '&larr; previous'
    format % link_to(text, previous_topic_path(@section, @topic.permalink), options)
  end
  
  def link_to_next_topic(*args)
    options = args.extract_options!
    format = options.delete(:format) || '%s'
    topic = args.pop
    text = args.pop || 'next &rarr;'
    format % link_to(text, next_topic_path(@section, @topic.permalink), options)
  end
  
  def topic_attributes(topic, format = nil)
    attrs = []
    attrs << pluralize_str(@topic.comments_count, '%s posts')
    attrs << 'sticky' if topic.sticky?
    attrs << 'locked' if topic.locked?
    (format || '%s') % attrs.join(', ') unless attrs.empty?
  end
end