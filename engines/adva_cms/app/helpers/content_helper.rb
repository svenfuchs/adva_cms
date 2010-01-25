module ContentHelper
  def published_at_formatted(article)
    return t(:'adva.contents.not_published') unless article && article.published?
    l(article.published_at, :format => (article.published_at.year == Time.now.year ? :short : :long))
  end

  def section_path(section, options = {})
    send(:"#{section.type.downcase}_path", section, options)
  end

  def article_url(section, article, options = {})
    page_article_url(*[section, article.permalink, options].compact)
  end

	def article_path(section, article, options = {})
	  page_article_path(*[section, article.permalink, options].compact)
	end

  # TODO: move to Admin::ContentHelper?
  def admin_section_contents_path(section)
    content_type = section.class.content_type.pluralize.gsub('::', '_').underscore.downcase
    send(:"admin_#{content_type}_path", section.site, section)
  end

  def admin_section_contents_url(section)
    content_type = section.class.content_type.pluralize.gsub('::', '_').underscore.downcase
    send(:"admin_#{content_type}_url", section.site, section)
  end

  def content_status(content)
    return "<span>&nbsp;</span>" unless content.respond_to?(:published?)
    klass = content.published? ? 'published' : 'pending'
    text  = content.published? ? t(:'adva.titles.published') : t(:'adva.titles.pending')

    "<span title='#{text}' alt='#{text}' class='status #{klass}'>#{text}</span>"
  end

  def link_to_preview(*args)
    options = args.extract_options!
    content, text = *args.reverse

    text ||= :"adva.#{content.class.name.tableize}.links.preview"
    url = show_path(content, :cl => content.class.locale, :namespace => nil)

    options.reverse_merge!(:url => url, :class => "preview #{content.class.name.underscore}")
    link_to_show(text, content, options)
  end

  def link_to_content(*args)
    options = args.extract_options!
    object, text = *args.reverse
    link_to_show(text || (object.is_a?(Site) ? object.name : object.title), object, options) if object
  end

  def link_to_category(*args)
    text = args.shift if args.first.is_a?(String)
    category = args.pop
    section = args.pop || category.section
    route_name = :"#{section.class.name.downcase}_category_path"
    text ||= category.title
    link_to(h(text), send(route_name, :section_id => section.id, :category_id => category.id))
  end

  def links_to_content_categories(content, key = nil)
    return if content.categories.empty?
    links = content.categories.map { |category| link_to_category content.section, category }
    key ? t(key, :links => links.join(', ')) : links
  end

  def link_to_tag(*args)
    tag = args.pop
    section = args.pop
    route_name = :"#{section.class.name.downcase}_tag_path"
    text = args.pop || tag.name
    link_to(h(text), send(route_name, :section_id => section.id, :tags => tag))
  end

  def links_to_content_tags(content, key = nil)
    return if content.tags.empty?
    links = content.tags.map { |tag| link_to_tag content.section, tag }
    key ? t(key, :links => links.join(', ')) : links
  end

  def content_category_checkbox(content, category)
    type = content.type.downcase
    checked = content.categories.include?(category)
    name = "#{type}[category_ids][]"
    id = "#{type}_category_#{category.id}"
    check_box_tag(name, category.id, checked, :id => id)
  end
end
