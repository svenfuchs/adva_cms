# TODO move this to the base_helper?

module Admin::BaseHelper
  def admin_site_select_tag
    return unless current_user.has_role?(:superuser) || Site.multi_sites_enabled
    options = []

    if current_user.has_role?(:superuser)
      options << ['Sites overview', admin_sites_path]
      options << ['Superusers + Admins', admin_users_path]
      options << ['------------------', '#']
    end


    # TODO only show sites where the user actually has access to!
    options += Site.all.collect { |site| [site.name, admin_site_path(site)] }

    selection = options.reverse.detect { |name, url| request.path.starts_with?(url) }

    select_tag 'site-select', options_for_select(options, selection)
  end
  
  def link_to_profile(site = nil, options = {})
    name = options[:name].nil? ? 'Profile' : options[:name]
    
    if site.nil? || site.new_record? || current_user.has_role?(:superuser)
      link_to(name, admin_user_path(current_user))
    else
      link_to(name, admin_site_user_path(site, current_user))
    end
  end
end
