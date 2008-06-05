module Admin::BaseHelper

  def site_select_tag 
    options  = [['Site overview', admin_sites_path]]
    options += Site.find(:all).collect { |site| [site.name, admin_site_path(site)] }
    select_tag('site-select', options_for_select(options, admin_site_path(@site)))
  end
end
