# TODO move this to the base_helper?

module Admin::BaseHelper
  def save_or_cancel_links(builder, options = {})
    save_text   = options.delete(:save_text)   || t(:'adva.common.save')
    or_text     = options.delete(:or_text)     || t(:'adva.common.connector.or')
    cancel_text = options.delete(:cancel_text) || t(:'adva.common.cancel')
    cancel_url  = options.delete(:cancel_url)

    save_options = options.delete(:save) || {}
    save_options.reverse_merge!(:id => 'commit')
    cancel_options = options.delete(:cancel) || {}

    builder.buttons do
      returning '' do |buttons|
        buttons << submit_tag(save_text, save_options)
        buttons << " #{or_text} #{link_to(cancel_text, cancel_url, cancel_options)}" if cancel_url
      end
    end
  end

  def admin_site_select_tag
    return '' unless current_user.has_role?(:superuser) || Site.multi_sites_enabled
    options = []

    if current_user.has_role?(:superuser)
      options << [t(:'adva.links.sites_overview'), admin_sites_path]
      options << [t(:'adva.links.superusers_admins'), admin_users_path]
      options << ['------------------', '#']
    end

    # TODO only show sites where the user actually has access to!
    options += Site.all.collect { |site| [site.name, admin_site_path(site)] }

    selection = options.reverse.detect { |name, url| request.path.starts_with?(url) }

    select_tag 'site_select', options_for_select(options, selection)
  end

  def link_to_profile(site = nil, options = {})
    name = options[:name].nil? ? t(:'adva.links.profile') : options[:name]

    if site.nil? || site.new_record? || current_user.has_role?(:superuser)
      link_to(name, admin_user_path(current_user))
    else
      link_to(name, admin_site_user_path(site, current_user))
    end
  end

  def links_to_content_translations(content, &block)
    return '' if content.new_record?
    block = Proc.new { |locale| link_to_edit(locale, content, :cl => locale) } unless block
    locales = content.translated_locales.map { |locale| block.call(locale.to_s) }
    content_tag(:span, :class => 'content_translations') do
      t(:"adva.#{content[:type].tableize}.translation_links", :locales => locales.join(', '))
    end
  end

  def link_to_clear_cached_pages(site)
    link_to(t(:'adva.cached_pages.links.clear_all'), admin_cached_pages_path(site), :method => :delete)
  end

  def link_to_restore_plugin_defaults(site, plugin)
    link_to(t(:'adva.titles.restore_defaults'), admin_plugin_path(site, plugin), :confirm => t(:'adva.plugins.confirm_reset'))
  end

  def page_cached_at(page)
    if Date.today == page.updated_at.to_date
      if page.updated_at > Time.zone.now - 4.hours
        "#{time_ago_in_words(page.updated_at).gsub(/about /,'~ ')} ago"
      else
        "Today, #{page.updated_at.strftime('%l:%M %p')}"
      end
    else
      page.updated_at.strftime("%b %d, %Y")
    end
  end

end
