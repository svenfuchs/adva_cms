# Frontend main sections menu
Menu.instance(:'default.sections', :class => 'menu') do
  if site = controller.site # FIXME why is @site nil here?
    site.sections.roots.each do |child|
      item child.title, :url => page_path(child)
    end
  end
end

# Backend menus
# Main menu
Menu.instance(:'admin.main.left', :class => 'left') do # :partial => 'admin/shared/menu'
  item :overview,   :url => admin_site_path(@site)
  item :sections,   :url => new_admin_section_path(@site)
  # item :settings,   :url => edit_admin_site_path(@site) # FIXME do we need this? is overview enough?
end

Menu.instance(:'admin.main.right', :class => 'right') do # :partial => 'admin/shared/menu'
  item :site_users, :url => admin_site_users_path(@site)
  item :profile,    :caption => link_to_profile(@site)
end

# adva-assets menus
Menu.instance(:'admin.assets.actions', :class => 'actions') do
  item :asset_create, :caption => link_to_new([@site, :asset])
	item :asset_upload, :caption => link_to_new(:'adva.assets.upload', [@site, :asset])
end

# adva-blog menus
Menu.instance(:'admin.blogs.manage', :class => 'manage') do
  item :articles,   :caption => link_to(t(:'adva.blog.links.articles'), admin_articles_path(@site, @section)), :id => 'manage_articles'
  item :categories, :caption => link_to(t(:'adva.blog.links.categories'), admin_categories_path(@site, @section)), :id => 'manage_categories'
  item :blog_settings,  :caption => link_to_edit(@section), :id => 'manage_settings'
end

Menu.instance(:'admin.blogs.actions', :class => 'actions') do
  item :new_article, :caption => link_to_new([@section, :article])
end

# adva-calendar menus
Menu.instance(:'admin.calendars.manage', :class => 'manage') do
    item :events,         :caption => link_to_index([@section, :calendar_events]), :id => 'manage_events'
    item :categories,     :caption => link_to_index([@section, :categories]), :id => 'manage_categories'
    item :calendar_settings,  :caption => link_to_edit(@section), :id => 'manage_settings'
end

Menu.instance(:'admin.calendars.actions', :class => 'actions') do
  item :create_event, :caption => link_to_new([@section, :calendar_event])

  if @event && !@event.new_record?
	  item :"event_preview",
	       :caption => link_to_preview(:"adva.calendar.links.#{@event.draft? ? 'preview' : 'show'}", @event)
	  item :"event_delete", :caption => link_to_delete(@event)
  end
end

# adva-cms article menus
Menu.instance(:'admin.articles.manage', :class => 'manage') do
	item :articles,     :caption => link_to_index([@section, :article])
	item :categories,   :caption => link_to_index([@section, :category])
  item :edit_section, :caption => link_to_edit(@section)
end

Menu.instance(:'admin.articles.actions', :class => 'actions') do
	item :create_article,   :caption => link_to_new([@section, :article])

  if @article && !@article.new_record?
	  item :preview_article,  :caption => link_to_preview(@article)
	  item :article_edit,     :caption => link_to_edit(@article)
    item :article_delete,   :caption => link_to_delete(@article)
  end
end

# adva-cms cached_page menus
Menu.instance(:'admin.sites.cached_pages.actions', :class => 'actions') do
  item :site_cache,
       :caption => link_to(content_tag(:span, t(:'adva.titles.clear_all')), admin_cached_pages_path,
                   :method => :delete, :id => 'clear_all_cached_pages')
end

# adva-cms categories menus
Menu.instance(:'admin.categories.actions', :class => 'actions') do
  item :create_category, :caption => link_to_new([@section, :category])

  if @category && !@category.new_record?
	  item :category_edit, :caption => link_to_edit(@category)
	  item :category_delete, :caption => link_to_delete(@category)
  end
end

# adva-cms pages menus
Menu.instance(:'admin.pages.articles.manage', :class => 'manage') do
  item :articles,   :caption => link_to(t(:'adva.titles.articles'), admin_articles_path(@site, @section)), :id => 'manage_articles'
  item :categories, :caption => link_to(t(:'adva.titles.categories'), admin_categories_path(@site, @section)), :id => 'manage_categories'
  item :page_settings,  :caption => link_to_edit(@section), :id => 'manage_settings'
end

Menu.instance(:'admin.pages.articles.actions', :class => 'actions') do
  item :article_create, :caption => link_to(t(:'adva.articles.links.create'), new_admin_article_path(@site))
end

# adva-cms plugins menus
Menu.instance(:'admin.plugins.manage', :class => 'manage') do
  item :plugins, :caption => link_to(content_tag(:span, t(:'adva.titles.plugins')), admin_plugins_path(@site))

  if @plugin
    item :restore_defaults, :caption => link_to(content_tag(:span, t(:'adva.titles.restore_defaults')),
                                                            admin_plugin_path(@site, @plugin),
                                                            :confirm => t(:'adva.sites.confirm_delete'),
                                                            :method => :delete)
  end
end

# adva-cms section menus
Menu.instance(:'admin.sections.manage', :class => 'manage') do
	@section.type == 'Album'
    item :photos, :caption => link_to('Photos', admin_photos_path(@site, @section))
    item :sets,   :caption => link_to('Sets', admin_sets_path(@site, @section))
	elsif @section.type == 'Forum'
		item :boards, :caption => link_to('Boards', admin_boards_path(@site, @section))
    item :forum,  :caption => link_to('Forum', forum_path(@section))
  else
  	item :articles, :caption   => link_to(t(:'adva.titles.articles'), admin_articles_path(@site, @section), :id => 'manage_articles')
    item :categories, :caption => link_to(t(:'adva.titles.categories'), admin_categories_path(@site, @section), :id => 'manage_categories')
  end
  
  item :settings, :caption => link_to(t(:'adva.titles.settings'), edit_admin_section_path(@site, @section), :id => 'manage_settings')
end

Menu.instance(:'admin.sections.actions', :class => 'actions') do
  item :section_create, :caption => link_to(t(:'adva.sections.links.create'), new_admin_section_path(@site))

  if @section && !@section.new_record?
    item :section_delete, :caption => link_to_delete(@section)
  end
end

# adva-cms site menus
Menu.instance(:'admin.sites.manage', :class => 'manage') do
  item :site_settings,
       :caption => link_to(t(:'adva.titles.settings'), edit_admin_site_path(@site), :id => 'manage_site')

  if Rails.plugin?(:adva_themes)
    item :"site_#{@site.id}_themes",
         :caption => link_to(t(:'adva.titles.themes'), admin_themes_path(@site), :id => 'manage_themes')
  end

  item :"site_#{@site.id}_cache",
       :caption => link_to(t(:'adva.titles.cache'), admin_cached_pages_path(@site), :id => 'manage_cache')
end

Menu.instance(:'admin.sites.actions', :class => 'actions') do
  item :site_create, :caption => link_to(content_tag(:span, 'New'), :action => "new")
  
  if @site && !@site.new_record?
    item :site_delete,
         :caption => link_to(t(:'adva.sites.links.delete'), admin_site_path(@site),
                     { :confirm => t(:'adva.sites.confirm_delete'), :method => :delete })
  end
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