# ActionController::Dispatcher.to_prepare do
#   Menu.reset!
# end

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
Menu.instance(:'admin.top.left', :class => 'left') do
  if @site and !@site.new_record?
    item :overview, :url => admin_site_path(@site)
    item :sections, :url => new_admin_section_path(@site)
  end
end

Menu.instance(:'admin.top.right', :class => 'right') do # :partial => 'admin/shared/menu'
  if @site and !@site.new_record?
    item :settings,   :url => edit_admin_site_path(@site)
    item :themes,     :caption => link_to_index([@site, :theme]) if Rails.plugin?(:adva_themes)
    item :site_users, :url => admin_site_users_path(@site)
  end
end

# adva-assets menus
Menu.instance(:'admin.assets.right', :class => 'right') do
  item :asset_create, :caption => link_to_new([@site, :asset])
end

# adva-calendar menus
Menu.instance(:'admin.calendar_events.left', :class => 'left') do
  item :events,             :caption => link_to_index([@section, :calendar_events]), :id => 'manage_events'
  item :categories,         :caption => link_to_index([@section, :categories]), :id => 'manage_categories'
  item :calendar_settings,  :caption => link_to_edit(@section), :id => 'manage_settings'
end

Menu.instance(:'admin.calendar_events.right', :class => 'right') do
  item :create_event, :caption => link_to_new([@section, :calendar_event])
  if @event && !@event.new_record?
	  item :"event_delete",  :caption => link_to_delete(@event)
  end
end


# adva-cms article menus
Menu.instance(:'admin.articles.left', :class => 'left') do
	item :articles,   :caption => link_to_index([@section, :article])
	item :categories, :caption => link_to_index([@section, :category])
  item :settings,   :caption => link_to_edit(@section)
end

Menu.instance(:'admin.articles.right', :class => 'right') do
	item :create_article,   :caption => link_to_new([@section, :article])
  if @article && !@article.new_record?
	  item :article_preview,  :caption => link_to_preview(@article)
	  item :article_edit,     :caption => link_to_edit(@article)
    item :article_delete,   :caption => link_to_delete(@article)
  end
end


# adva-cms cached_page menus
Menu.instance(:'admin.cached_pages.left', :class => 'left') do
  item :settings, :caption => link_to_edit(@site)
  # item :themes,   :caption => link_to_index([@site, :theme]) if Rails.plugin?(:adva_themes)
  item :cache,    :caption => link_to_index([@site, :cached_page])
end

Menu.instance(:'admin.cached_pages.right', :class => 'right') do
  item :cache, :caption => link_to(t(:'adva.cached_pages.links.clear_all'), admin_cached_pages_path, :method => :delete)
end

# adva-cms categories menus
Menu.instance(:'admin.categories.left', :class => 'left') do
	item :articles, :caption => link_to_index([@section, :article]) if @section.is_a?(Page)
	item :categories, :caption => link_to_index([@section, :category])
  item :settings,   :caption => link_to_edit(@section)
end

Menu.instance(:'admin.categories.left', :class => 'left') do # goes to adva_blog
	item :articles, :caption => link_to_index([@section, :article]), :before => :_first if @section.is_a?(Blog)
end

Menu.instance(:'admin.categories.left', :class => 'left') do # goes to adva_calendar
	item :events, :caption => link_to_index([@section, :calendar_event]), :before => :_first if @section.is_a?(Calendar)
end

Menu.instance(:'admin.categories.left', :class => 'left') do # goes to adva_wiki
	item :wikipages, :caption => link_to_index([@section, :wikipage]), :before => :_first if @section.is_a?(Wiki)
end

Menu.instance(:'admin.categories.right', :class => 'right') do
  item :create_category, :caption => link_to_new([@section, :category])
  if @category && !@category.new_record?
	  item :category_edit, :caption => link_to_edit(@category)
	  item :category_delete, :caption => link_to_delete(@category)
  end
end

# adva-cms plugins menus
Menu.instance(:'admin.plugins.right', :class => 'right') do
  item :plugins, :caption => link_to(t(:'adva.titles.plugins'), admin_plugins_path(@site))

  if @plugin
    item :restore_defaults, :caption => link_to(t(:'adva.titles.restore_defaults'), admin_plugin_path(@site, @plugin),
                                                :confirm => t(:'adva.plugins.confirm_reset'))
  end
end

# adva-cms section menus
Menu.instance(:'admin.sections.left', :class => 'left') do
  if @section.is_a?(Page) && !@section.new_record?
    item :articles,   :caption => link_to_index([@section, :article])
    item :categories, :caption => link_to_index([@section, :category])
    item :settings,   :caption => link_to_edit(@section)
  end
end

Menu.instance(:'admin.sections.left', :class => 'left') do # goes to adva_blog
  if @section.is_a?(Blog) && !@section.new_record?
    item :articles,   :caption => link_to_index([@section, :article])
    item :categories, :caption => link_to_index([@section, :category])
    item :settings,   :caption => link_to_edit(@section)
  end
end

Menu.instance(:'admin.sections.left', :class => 'left') do # goes to adva_calendar
  if @section.is_a?(Calendar) && !@section.new_record?
	  item :events,     :caption => link_to_index([@section, :calendar_event])
    item :categories, :caption => link_to_index([@section, :category])
    item :settings,   :caption => link_to_edit(@section)
  end
end

Menu.instance(:'admin.sections.left', :class => 'left') do # goes to adva_forum
  if @section.is_a?(Forum) && !@section.new_record?
	  item :boards,     :caption => link_to_index([@section, :board])
    item :settings,   :caption => link_to_edit(@section)
  end
end

Menu.instance(:'admin.sections.left', :class => 'left') do # goes to adva_photos
  if @section.is_a?(Album) && !@section.new_record?
	  item :photos,     :caption => link_to_index([@section, :photo])
    item :sets,       :caption => link_to_index([@section, :set])
    item :settings,   :caption => link_to_edit(@section)
  end
end

Menu.instance(:'admin.sections.left', :class => 'left') do # goes to adva_wiki
  if @section.is_a?(Wiki) && !@section.new_record?
	  item :wikipages,  :caption => link_to_index([@section, :wikipage])
    item :categories, :caption => link_to_index([@section, :category])
    item :settings,   :caption => link_to_edit(@section)
  end
end

Menu.instance(:'admin.sections.right', :class => 'right') do
  # item :section_create, :caption => link_to(t(:'adva.sections.links.create'), new_admin_section_path(@site))
  if @section && !@section.new_record?
    item :section_delete, :caption => link_to_delete(@section)
  end
end

# adva-cms site menus
Menu.instance(:'admin.sites.left', :class => 'left') do
  item :settings, :caption => link_to_edit(@site)
  # item :themes, :caption => link_to_index([@site, :theme]) if Rails.plugin?(:adva_themes)
  item :cache, :caption => link_to_index([@site, :cached_page])
end

Menu.instance(:'admin.sites.right', :class => 'right') do
  item :new, :caption => link_to('New', :action => "new") if Site.multi_sites_enabled
  if @site && !@site.new_record?
    item :delete, :caption => link_to_delete(@site)
  end
end

# adva-forum menus
Menu.instance(:'admin.boards.left', :class => 'left') do
  item :boards,   :caption => link_to_index([@section, :board])
  item :settings, :caption => link_to_edit(@section)
end

Menu.instance(:'admin.boards.right', :class => 'right') do
  item :new, :caption => link_to_new([@section, :board])
end

# adva-newsletters menus

Menu.instance(:'admin.newsletters.left', :class => 'left') do
  item :newsletters, :caption => link_to_index([@site, :newsletter])
end

Menu.instance(:'admin.newsletters.right', :class => 'right') do
  item :new, :caption => link_to_new([@site, :newsletter])
  if @newsletter.present? && !@newsletter.new_record?
    item :issues, :caption => link_to_index([@newsletter, :issue])
    item :edit, :caption => link_to_edit(@newsletter)
    item :delete, :caption => link_to_delete(@newsletter)
  end
end

# adva-newsletters issues menus

Menu.instance(:'admin.issues.right', :class => 'right') do
  item :new, :caption => link_to_new([@newsletter, :issue])

  if @issue.present? # && @issue.editable?
    item :edit,    :caption => link_to_edit(@issue)
    item :preview, :caption => link_to(t(:"adva.newsletter.link.send_preview_issue"),
                                      admin_delivery_path(@site, @newsletter, @issue),
                                      :method => :post, :confirm => t(:"adva.newsletter.confirm.send_preview_issue"))
  end

  if @issue.present? && !@issue.new_record?
    item :delete, :caption => link_to_delete(@issue)
  end
end

# adva-photos menus
Menu.instance(:'admin.photos.left', :class => 'left') do
  item :photos,   :caption => link_to_index([@section, :photo])
  item :sets,     :caption => link_to(t(:'adva.photos.common.sets'), admin_sets_path(@site, @section))
  item :settings, :caption => link_to_edit(@section)
end

Menu.instance(:'admin.photos.right', :class => 'right') do
	item :new, :caption => link_to_new([@section, :photo])
	if @photo && !@photo.new_record?
	  item :edit,   :caption => link_to_edit(@photo)
	  item :delete, :caption => link_to_delete(@photo)
  end
end

# adva-photos sets menus
Menu.instance(:'admin.sets.left', :class => 'left') do
	item :photos,   :caption => link_to_index([@section, :photo])
	item :sets,     :caption => link_to_index([@section, :set])
  item :settings, :caption => link_to_edit(@section)
end

Menu.instance(:'admin.sets.right', :class => 'right') do
  item :new, :caption => link_to_new(:'adva.sets.links.new', [@section, :set])
  if @set && !@set.new_record?
    item :edit,   :caption => link_to_edit(:'adva.sets.links.edit', @set)
    item :delete, :caption => link_to_delete(:'adva.sets.links.delete', @set)
  end
end

# adva-themes menus
Menu.instance(:'admin.themes.left', :class => 'left') do
  item :themes, :caption => link_to_index([@site, :theme]) if Rails.plugin?(:adva_themes)
end

Menu.instance(:'admin.themes.right', :class => 'right') do
  unless @theme.present?
    item :new, :caption => link_to_new([@site, :theme])
    item :import, :caption => link_to(t(:'adva.themes.links.import'), import_admin_themes_path(@site))
  end

  if @theme.present? && !@theme.new_record?
    item :new_file, :caption => link_to_new(:'adva.theme_files.links.new_file', [@theme, :'theme/file'])

    if @theme.active?
      item :unselect, :caption => link_to(t(:'adva.themes.links.unselect'), admin_site_selected_theme_path(@site, @theme),
                                          :confirm => t(:'adva.themes.confirm_unselect'), :method => :delete)
    else
      item :select,   :caption => link_to(t(:'adva.themes.links.select'), admin_site_selected_themes_path(@site, :id => @theme.id),
                                          :confirm => t(:'adva.themes.confirm_select'), :method => :post)
    end

    item :edit,     :caption => link_to_edit(@theme)
    item :download, :caption => link_to(t(:'adva.themes.links.download'), export_admin_theme_path(@site, @theme))
    item :delete,   :caption => link_to_delete(@theme)
  end
end

# adva-themes theme-files menus
Menu.instance(:'admin.theme_files.left', :class => 'left') do
  item :themes, :caption => link_to_index([@site, :theme])
  item :themes, :caption => link_to_show(@theme.name, @theme)
end

Menu.instance(:'admin.theme_files.right', :class => 'right') do
  item :new, :caption => link_to_new([@theme, :'theme/file'])
  item :upload, :caption => link_to(t(:'adva.theme_files.links.upload'), import_admin_theme_files_path(@site, @theme.id))
  if @file.present? and !@file.new_record?
    item :delete, :caption => link_to(t(:'adva.theme_files.links.delete'), admin_theme_file_path(@site, @theme.id, @file.id),
                                      :confirm => t(:'adva.theme_files.confirm_delete'), :method => :delete)
  end
end

# adva-user menus
Menu.instance(:'admin.users.right', :class => 'right') do
  item :new, :caption => link_to(t(:'adva.users.links.new'), new_member_path)

  if @user && !@user.new_record?
    item :edit,   :caption => link_to_edit(@user)
    item :delete, :caption => link_to_delete(@user)
  end
end

# adva-wiki menus
Menu.instance(:'admin.wikipages.left', :class => 'left') do
  item :wikipages,  :caption => link_to_index([@section, :wikipage])
  item :categories, :caption => link_to_index([@section, :category])
  item :settings,   :caption => link_to_edit(@section)
end

Menu.instance(:'admin.wikipages.right', :class => 'right') do
  item :wikipage_new, :caption => link_to_new([@section, :wikipage])
  if @wikipage && !@wikipage.new_record?
    item :wikipage_show,   :caption => link_to_show(@wikipage, :url => show_path(@wikipage, :namespace => nil))
    item :wikipage_delete, :caption => link_to_delete(@wikipage)
  end
end





# <% content_for :sidebar do %>
#   <%= render :partial => "admin/shared/sidebar_manage" %>
#   <%= render :partial => "sidebar_actions" %>
# <% end %>
# 
# <% content_for :sidebar do %>
#   <%= render :partial => 'admin/shared/sidebar_manage' %>
#   <h3><%= t(:'adva.titles.actions') %></h3>
#   <ul>
#     <li><%= link_to_new(:'adva.newsletter.link.new_issue', [@newsletter, :issue]) %></li>
#     <li><%= link_to_new(:'adva.subscription.link.new', [@newsletter, :subscription]) %></li>
#     <li><%= link_to t(:'adva.users.links.new'), new_admin_site_user_path %></li>
#   </ul>
# <% end %>
# <h3><%= t(:"adva.titles.actions") %></h3>
# <ul>
#   <% if @issue.present? && @issue.editable?  %>
#     <li><%= link_to_edit :"adva.newsletter.link.edit_issue", @issue %></li>
#     <li>
#       <%= link_to t(:"adva.newsletter.link.send_preview_issue"), admin_delivery_path(@site, @newsletter, @issue),
#       :method => :post, :confirm => t(:"adva.newsletter.confirm.send_preview_issue") %>
#     </li>
#   <% end %>
# 
#   <%= render :partial => 'admin/shared/sidebar_common' %>
# 
#   <% if @issue.present? && !@issue.new_record? %>
#     <li><%= link_to_delete :"adva.newsletter.link.delete_issue", @issue %></li>
#   <% end %>
# </ul>
# <h3><%= t(:'adva.titles.actions') %></h3>
# <ul>
#   <li><%= link_to_new :'adva.newsletter.link.new_issue', [@newsletter, :issue] %></li>
#   <li><%= link_to_new :'adva.subscription.link.new', [@issue, :issue], :url => new_admin_subscription_path %></li>
# </ul>
# <h3><%= t(:'adva.titles.manage') %></h3>
# <ul>
#   <li <%= active_li?("admin/newsletters") %>>
#     <%= link_to t(:'adva.newsletter.link.index'), admin_newsletters_path %>
#   </li>
#   <% if @newsletter.present? && !@newsletter.new_record? %>
#     <li <%= active_li?("admin/issues") %> ><%= link_to t(:'adva.newsletter.link.issues'), admin_issues_path(@site, @newsletter) %></li>
#     <li <%= active_li?("admin/newsletter_subscriptions") %> ><%= link_to t(:'adva.newsletter.link.subscribers'), admin_subscriptions_path(@site, @newsletter) %></li>
#   <% end %>
# </ul>

