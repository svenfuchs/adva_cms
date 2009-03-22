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

  def links_to_content_translations(content)
    locales = content.translated_locales.map { |locale| block_given? ? yield(locale.to_s) : locale }
    t(:"adva.#{content[:type].tableize}.translation_links", :locales => locales.join(', '))
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
