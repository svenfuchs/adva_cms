class ActionView::Base
  unless method_defined? :method_missing_with_returning_paths
    def method_missing_with_returning_paths(name, *args)
      name = name.to_s
      if name.sub!(/_returning(_path|_url)$/, '')
        options = args.extract_options!
        options.reverse_merge! :return_to => params[:return_to] || request.request_uri
        args << options
        send :"#{name}#{$1}", *args
      else
        method_missing_without_returning_paths name.to_sym, *args
      end
    end
    alias_method_chain :method_missing, :returning_paths
  end
end

module BaseHelper
  def link_to_section_main_action(site, section)
    case section
    when Wiki
      link_to content_tag(:span, t(:'adva.titles.wikipages')), admin_wikipages_path(site, section)
    when Forum
      link_to content_tag(:span, t(:'adva.titles.boards')), admin_boards_path(site, section)
    when Section, Blog
      link_to content_tag(:span, t(:'adva.titles.articles')), admin_articles_path(site, section)
    end
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

  # # same as Rails text helper, but returns only the pluralized string without
  # # the number botched into it
  # def pluralize_str(count, singular, plural = nil)
  #   str = if count.to_i == 1
  #     singular
  #   elsif plural
  #     plural
  #   elsif ActiveSupport.const_defined?("Inflector")
  #     ActiveSupport::Inflector.pluralize(singular)
  #   else
  #     singular + "s"
  #   end
  #   str % count.to_i
  # end

  def todays_short_date
    Time.zone.now.to_ordinalized_s(:stub)
  end

  def yesterdays_short_date
    Time.zone.now.yesterday.to_ordinalized_s(:stub)
  end

  def datetime_with_microformat(datetime, options={})
    return datetime unless datetime.respond_to?(:strftime)
    options.symbolize_keys!
    options[:format] ||= :standard
    # yuck ... use the localized_dates plugin as soon as we're on Rails 2.2?
    formatted_datetime = options[:format].is_a?(Symbol) ? datetime.clone.in_time_zone.to_s(options[:format]) : datetime.clone.in_time_zone.strftime(options[:format])

    %{<abbr class="datetime" title="#{datetime.utc.xmlschema}">#{formatted_datetime}</abbr>}
  end

  def filter_options
    FilteredColumn.filters.keys.inject([]) do |arr, key|
      arr << [FilteredColumn.filters[key].filter_name, key.to_s]
    end.unshift [t(:'adva.settings.filter_options.plain_html'), '']
  end

  def author_options
    members = [[current_user.name, current_user.id]]
    return members if @site.users.empty?

    members += @site.users.collect {|member| [member.name, member.id]}
    members.uniq.sort
  end

  def author_preselect
    content = (@article || @wikipage)
    return current_user.id if content.nil?
    content.author ? content.author.id : current_user.id
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
