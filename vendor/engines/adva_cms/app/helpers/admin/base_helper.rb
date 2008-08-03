# TODO move this to the base_helper?

module Admin::BaseHelper
  def admin_site_select_tag(path, user)
    # TODO only show sites where the user actually has access to!
    options  = []
    options += Site.find(:all).collect { |site| [site.name, path] }
    select_tag 'site-select', options_for_select(options, path)
  end

  def admin_global_select_tag(path)
    options = []
    options  = [['Sites overview', admin_sites_path]]
    options << ['Superusers + Admins', admin_users_path]
    options << ['------------------', '#']
    options += Site.find(:all).collect { |site| [site.name, path] }
    select_tag 'site-select', options_for_select(options, path)
  end
end
