module ForumHelper
  def confirm_board_delete(forum)
    if forum.boards.size == 1
      t(:'adva.boards.confirm_delete_on_last')
    else
      t(:'adva.boards.confirm_delete')
    end
  end
  
  def forum_boards_select(forum)
    forum.boards.collect {|b| [b.title, b.id]}
  end
  
  def link_to_topic(*args)
    options = args.extract_options!
    topic = args.pop
    text = args.pop || topic.title
    link_to text, topic_path(topic.section, topic.permalink), options
  end

  def link_to_last_post(*args)
    options = args.extract_options!
    topic = args.pop
    return '' unless topic.last_post
    text = args.pop || topic.last_post.created_at.to_s(:long)
    options[:anchor] = dom_id(topic.last_post)
    options[:page] = topic.last_page if topic.last_page > 1
    link_to text, topic_path(topic.section, topic.permalink), options
  end

  def link_to_prev_topic(*args)
    options = args.extract_options!
    format = options.delete(:format) || '%s'
    topic = args.pop
    text = args.pop || '&larr; ' + I18n.t(:'adva.links.previous')
    format % link_to(text, previous_topic_path(topic.section, topic.permalink), options)
  end

  def link_to_next_topic(*args)
    options = args.extract_options!
    format = options.delete(:format) || '%s'
    topic = args.pop
    text = args.pop || I18n.t(:'adva.links.next') + ' &rarr;'
    format % link_to(text, next_topic_path(topic.section, topic.permalink), options)
  end

  def links_to_prev_next_topics(topic, options = {})
    separator = options.delete(:separator) || ' '
    format = options.delete(:format) || '%s'
    links = [link_to_prev_topic(options[:prev], topic), link_to_next_topic(options[:next], topic)]
    format % links.compact.join(separator)
  end

  def topic_attributes(topic, format = nil)
    attrs = []
    attrs << t(:'adva.topics.titles.post_count', :count => topic.posts_count)
    attrs << t(:'adva.topics.states.sticky') if topic.sticky?
    attrs << t(:'adva.topics.states.locked') if topic.locked?
    (format || '%s') % attrs.join(', ') if attrs.present?
  end
end