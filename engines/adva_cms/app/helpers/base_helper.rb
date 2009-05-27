module BaseHelper
  def column(&block)
    content_tag(:div, :class => 'col', &block)
  end
  
  def buttons(&block)
    content_tag(:p, :class => 'buttons', &block)
  end

  # does exactly the same as the form_for helper does, but splits off the
  # form head tag and captures it to the content_for :form collector
  def split_form_for(*args, &block)
    # for some weird reasons Passenger and Mongrel behave differently when using Rails' capture method
    # with_output_buffer -> works, so we use it for now
    lines = (with_output_buffer { form_for(*args, &block) } || '').split("\n")
    content_for :form, lines.shift
    lines.pop

    concat lines.join("\n")
  end

  def datetime_with_microformat(datetime, options={})
    return datetime unless datetime.respond_to?(:strftime)
    options.symbolize_keys!
    options[:format] ||= :default
    options[:type]   ||= :time
    # yuck ... use the localized_dates plugin as soon as we're on Rails 2.2?
    # formatted_datetime = options[:format].is_a?(Symbol) ? datetime.clone.in_time_zone.to_s(options[:format]) : datetime.clone.in_time_zone.strftime(options[:format])
    formatted_datetime = l(datetime.in_time_zone.send(options[:type].to_sym == :time ? :to_time : :to_date), :format => options[:format])

    %{<abbr class="datetime" title="#{datetime.utc.xmlschema}">#{formatted_datetime}</abbr>}
  end

  def filter_options
    FilteredColumn.filters.keys.inject([]) do |arr, key|
      arr << [FilteredColumn.filters[key].filter_name, key.to_s]
    end.unshift [t(:'adva.settings.filter_options.plain_html'), '']
  end

  def author_options(users)
    authors = [[current_user.name, current_user.id]] 
    authors += users.map { |author| [author.name, author.id] }
    authors.uniq
  end

  def author_selected(content)
    content.try(:author_id) || current_user.id
  end

  # Helper for adding active class to menu li
  #
  # Usage:
  #   <li <%= active_li?('issues') %>>my menu li</li>
  #
  def active_li?(controller_name)
    'class="active"' if params[:controller] == controller_name
  end
end
