# Frontend main sections menu
Menu.instance(:'default.sections', :class => 'menu') do
  if site = controller.site # FIXME why is @site nil here?
    site.sections.roots.each do |child|
      item child.title, :url => page_path(child)
    end
  end
end

# Backend menus
Menu.instance(:'admin.main.left', :class => 'left') do # :partial => 'admin/shared/menu'
  item :overview,   :url => admin_site_path(@site)
  item :sections,   :url => new_admin_section_path(@site)
  # item :settings,   :url => edit_admin_site_path(@site) # FIXME do we need this? is overview enough?
end

Menu.instance(:'admin.main.right', :class => 'right') do # :partial => 'admin/shared/menu'
  item :site_users, :url => admin_site_users_path(@site)
  item :profile,    :caption => link_to_profile(@site)
end

# Site menus
Menu.instance(:'admin.sites.manage', :class => 'manage') do
  item "site_#{@site.id}_settings",
       { :caption => link_to(t(:'adva.titles.settings'), edit_admin_site_path(@site), :id => 'manage_site') }
       
  if Rails.plugin?(:adva_themes)
    item "site_#{@site.id}_themes",
         { :caption => link_to(t(:'adva.titles.themes'), admin_themes_path(@site), :id => 'manage_themes') }
  end
  
  item "site_#{@site.id}_cache",
       { :caption => link_to(t(:'adva.titles.cache'), admin_cached_pages_path(@site), :id => 'manage_cache') }
end

Menu.instance(:'admin.sites.actions', :class => 'actions') do
  item "site_#{@site.id}_delete",
       { :caption => link_to(t(:'adva.sites.links.delete'), admin_site_path(@site),
                     { :confirm => t(:'adva.sites.confirm_delete'), :method => :delete }) }
end

# Themes
Menu.instance(:'admin.sites.themes.actions', :class => 'actions') do
  unless @theme.present?
    item 'create_theme', :caption => link_to(t(:'adva.themes.links.new_theme'), new_admin_theme_path(@site))
  end
  item 'import_theme', :caption => link_to(t(:'adva.themes.links.import_theme'), import_admin_themes_path(@site))
    
  if @theme.present? && !@theme.new_record?
    item 'create_theme', :caption => link_to(t(:'adva.themes.links.new_theme'), new_admin_theme_path(@site))
    
    if @theme.active?
      item "unselect_#{@theme.id}_theme",
           :caption => link_to(t(:'adva.themes.links.unselect_theme'), admin_site_selected_theme_path(@site, @theme),
                       { :confirm => t(:'adva.themes.confirm_unselect'), :method => :delete })
    else
      item "select_#{@theme.id}_theme",
           :caption => link_to(t(:'adva.themes.links.select_theme'), admin_site_selected_themes_path(@site, :id => @theme.id),
                       { :confirm => t(:'adva.themes.confirm_select'), :method => :post })
    end
    
    item "edit_#{@theme.id}_theme", :caption => link_to(t(:'adva.themes.links.edit_theme'),
                                                edit_admin_theme_path(@site, @theme))
    item "download_#{@theme.id}_theme", :caption => link_to(t(:'adva.themes.links.download_theme'),
                                                    export_admin_theme_path(@site, @theme))
  end
end

# Theme files
Menu.instance(:'admin.sites.themes.files.actions', :class => 'actions') do
  item 'create_theme_file', :caption => link_to(t(:'adva.themes.links.create_file'), new_admin_theme_file_path(@site, @theme.id))
  item 'upload_theme_file', :caption => link_to(t(:'adva.themes.links.upload_file'), import_admin_theme_files_path(@site, @theme.id))
  item 'delete_theme_file', :caption => link_to(t(:'adva.themes.links.delete_file'), admin_theme_file_path(@site, @theme.id, @file.id),
                                        { :confirm => "Are you sure you wish to delete this file?", :method => :delete })
  item 'edit_theme_file', :caption => link_to(t(:'adva.themes.links.edit_theme'), edit_admin_theme_path(@site, @theme.id))
  item 'download_theme_file', :caption => link_to(t(:'adva.themes.links.download_theme'), export_admin_theme_path(@site, @theme.id))
end

# Cache
Menu.instance(:'admin.sites.cache.actions', :class => 'actions') do
  item "site_#{@site.id}_cache",
       :caption => link_to(content_tag(:span, t(:'adva.titles.clear_all')), admin_cached_pages_path,
                   :method => :delete, :id => 'clear_all_cached_pages')
end

# Newsletters

Menu.instance(:'admin.newsletters.manage', :class => 'manage') do
  # active_newsletters = active_li?("admin/newsletters")
  # active_issues      = active_li?("admin/issues")
  # active_subscriptions = active_li?("admin/newsletter_subscriptions")
  
  if @newsletter.present? && !@newsletter.new_record?
    item 'issues', :caption => link_to(t(:'adva.newsletter.link.issues'), admin_issues_path(@site, @newsletter))
    item 'subscriptions', :caption => link_to(t(:'adva.newsletter.link.subscribers'), admin_subscriptions_path(@site, @newsletter))
  end
end

Menu.instance(:'admin.newsletters.actions', :class => 'actions') do
  item "create_newsletter", :caption => new_resource_link(Newsletter, new_admin_newsletter_path(@site),
                                        :text => t(:'adva.newsletter.link.new'))
end

# Issues

Menu.instance(:'admin.issues.actions', :class => 'actions') do
  item "create_issue", :caption => new_resource_link(Issue, new_admin_issue_path(@site, @newsletter),
                                   :text => t(:'adva.newsletter.link.new_issue'))
                                   
  if @issue.present? && @issue.editable?
    item "issue_#{@issue.id}_edit", :caption => edit_resource_link(@issue, edit_admin_issue_path(@site, @newsletter, @issue),
                                                :text => t(:"adva.newsletter.link.edit_issue"))
    
    item "issue_preview", :caption => link_to(t(:"adva.newsletter.link.send_preview_issue"),
                                      admin_delivery_path(@site, @newsletter, @issue),
                                      :method => :post, :confirm => t(:"adva.newsletter.confirm.send_preview_issue"))
  end
  
  if @issue.present? && !@issue.new_record?
    item "delete_issue", :caption => delete_resource_link(@issue, admin_issue_path(@site, @newsletter, @issue),
                                     :text => t(:"adva.newsletter.link.delete_issue"))
  end
end