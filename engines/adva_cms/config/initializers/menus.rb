Menu.instance(:'default.sections', :class => 'menu') do
  if site = controller.site # FIXME why is @site nil here?
    site.sections.roots.each do |child|
      item child.title, :url => page_path(child)
    end
  end
end

Menu.instance(:'admin.main.left', :class => 'left') do # :partial => 'admin/shared/menu'
  item :overview,   :url => admin_site_path(@site)
  item :sections,   :url => new_admin_section_path(@site)
  item :settings,   :url => edit_admin_site_path(@site)
end

Menu.instance(:'admin.main.right', :class => 'right') do # :partial => 'admin/shared/menu'
  item :site_users, :url => admin_site_users_path(@site)
  item :profile,    :caption => link_to_profile(@site)
end
