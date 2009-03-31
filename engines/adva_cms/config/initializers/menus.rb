# Menus.instance(:'admin.sites.left', :class => 'left') do
#   item :settings, :url => edit_path(@site)
#   item :cache,    :url => index_path([@site, :cached_page])
# end
#
# Menus.instance(:'admin.sites.right', :class => 'right') do
#   item :new, :url => new_path([:site]) if Site.multi_sites_enabled
#   if @site && !@site.new_record?
#     item :delete, :caption => link_to_delete(@site)
#   end
# end

# menu :sections, :url => new_path([@site, :section]), :class => :sections do
#   @site.sections.each do |section|
#     item(section.title, :url =>  admin_section_contents_path(section), :id => dom_id(section))
#   end
# end

def link_to_cached_pages_clear(site)
  link_to(t(:'adva.cached_pages.links.clear_all'), admin_cached_pages_path(site), :method => :delete)
end

def link_to_plugin_restore_defaults(site, plugin)
  link_to(t(:'adva.titles.restore_defaults'), admin_plugin_path(site, plugin), :confirm => t(:'adva.plugins.confirm_reset'))
end

def link_to_deactivate_theme(theme)
  link_to(t(:'adva.themes.links.deactivate'), admin_site_selected_theme_path(theme.site, theme), 
          :confirm => t(:'adva.themes.confirm_deactivate'), :method => :delete)
end

def link_to_activate_theme(theme)
  link_to(t(:'adva.themes.links.activate'), admin_site_selected_themes_path(theme.site, :id => theme.id),
          :confirm => t(:'adva.themes.confirm_activate'), :method => :post)
end

def link_to_delete_theme_file(file)
  link_to(t(:'adva.theme_files.links.delete'), admin_theme_file_path(file.theme.site, file.theme.id, file.id),
          :confirm => t(:'adva.theme_files.confirm_delete'), :method => :delete)
end

def link_to_delete_set(set)
  link_to_delete(set, :url => admin_set_path(set.section.site, set.section, set), :confirm => :'adva.photos.admin.sets.delete_confirmation')
end

# Backend top menus
Menus.instance(:admin) do
  if @site and !@site.new_record?
    item :overview, :url => admin_site_path(@site), :branch => :left

    item :sections, :url => index_path([@site, :section]), :branch => :left do 
      item :sections, :url => index_path([@site, :section]) do
        item :new, :url => new_path([@site, :section])
        if @section and !@section.new_record?
          item :settings, :url => edit_path(@section)
          item :delete,   :caption => link_to_delete(@section)
        end
      end
      
      if @section and !@section.new_record?
        case @section
        when Blog, Page
          item :articles, :url => index_path([@section, :article]) do
            item :new, :url => new_path([@section, :article])
            if @article and !@article.new_record?
              item :edit,   :url => edit_path(@article)
              item :delete, :caption => link_to_delete(@article)
            end
          end
          item :categories, :url => index_path([@section, :category]) do
            item :new, :url => new_path([@section, :category])
            if @category && !@category.new_record?
              item :edit, :url => edit_path(@category)
              item :delete, :caption => link_to_delete(@category)
            end
          end
        when Calendar
          item :events, :url => index_path([@section, :calendar_event]) do
            item :new, :url => new_path([@section, :calendar_event])
            if @event and !@event.new_record?
              item :edit,   :url => edit_path(@event)
              item :delete, :caption => link_to_delete(@event)
            end
          end
          item :categories, :url => index_path([@section, :category]) do
            item :new, :url => new_path([@section, :category])
            if @category && !@category.new_record?
              item :edit, :url => edit_path(@category)
              item :delete, :caption => link_to_delete(@category)
            end
          end
        when Forum
          item :boards, :url => index_path([@section, :board]) do
            item :new, :url => new_path([@section, :board])
            if @board and !@board.new_record?
              item :edit,   :url => edit_path(@board)
              item :delete, :caption => link_to_delete(@board)
            end
          end
        when Album
          item :photos, :url => index_path([@section, :photo]) do
            item :new, :url => new_path([@section, :photo])
            if @photo and !@photo.new_record?
              item :edit,   :url => edit_path(@photo)
              item :delete, :caption => link_to_delete(@photo)
            end
          end
          item :sets, :url => index_path([@section, :set]) do
            item :new, :url => new_path([@section, :set])
            if @set && !@set.new_record?
              item :edit, :url => edit_admin_set_path(@site, @section, @set)
              item :delete, :caption => link_to_delete_set(@set)
            end
          end
        when Wiki
          item :wikipages, :url => index_path([@section, :wikipage]) do
            item :new, :url => new_path([@section, :wikipage])
            if @wikipage and !@wikipage.new_record?
              item :edit,   :url => edit_path(@wikipage)
              item :delete, :caption => link_to_delete(@wikipage)
            end
          end
          item :categories, :url => index_path([@section, :category]) do
            item :new, :url => new_path([@section, :category])
            if @category && !@category.new_record?
              item :edit, :url => edit_path(@category)
              item :delete, :caption => link_to_delete(@category)
            end
          end
        end
      end
    end

    # adva-assets
    item :assets, :url => admin_assets_path(@site), :branch => :left do # :after => :last
      item :assets, :url => admin_assets_path(@site) do
        item :new, :url => new_path([@site, :asset])
        if @asset and !@asset.new_record?
          item :edit,   :url => edit_path(@asset)
          item :delete, :caption => link_to_delete(@asset)
        end
      end
    end

    # adva-newsletter
    item :newsletters, :url => index_path([@site, :newsletter]), :branch => :left do # :after => :last
      item :newsletters, :url => index_path([@site, :newsletter]) do
        item :new, :url => new_path([@site, :newsletter])
        if @newsletter and !@newsletter.new_record?
          item :edit,   :url => edit_path(@newsletter)
          item :delete, :caption => link_to_delete(@newsletter)
        end
      end

      if @newsletter and !@newsletter.new_record?
        item :issues, :url => index_path([@newsletter, :issue]) do
          item :new, :url => new_path([@newsletter, :issue])
          if @issue and !@issue.new_record?
            item :show,   :url => show_path(@issue)
            item :edit,   :url => edit_path(@issue)
            item :delete, :caption => link_to_delete(@issue)
          end
        end
        item :subscriptions, :url => index_path([@newsletter, :subscription]) do
          item :new, :url => new_path([@newsletter, :subscription])
        end
      end
    end

    # adva-themes
    item :themes, :url => index_path([@site, :theme]), :branch => :right do
      item :themes, :url => index_path([@site, :theme]) do
        if @theme and !@theme.new_record?
          # item :show,   :url => show_path(@theme)
          item :edit,   :url => edit_path(@theme)
          if @theme.active?
            item :deactivate, :caption => link_to_deactivate_theme(@theme)
          else
            item :activate, :caption => link_to_activate_theme(@theme)
          end
          item :download, :url => export_admin_theme_path(@site, @theme)
          item :delete, :caption => link_to_delete(@theme)
        else
          item :new, :url => new_path([@site, :theme])
          item :import, :url => import_admin_themes_path(@site)
        end
      end
      if @theme and !@theme.new_record?
        item :files, :url => show_path(@theme) do
          item :new, :url => new_path([@theme, :'theme/file'])
          item :upload, :url => import_admin_theme_files_path(@site, @theme.id)
          if @file and !@file.new_record?
            item :edit,   :url => admin_theme_file_path(@site, @theme.id, @file)
            item :delete, :caption => link_to_delete_theme_file(@file)
          end
        end
      end
    end

    item :settings, :url => edit_admin_site_path(@site), :branch => :right do
      item :settings, :url => edit_path(@site)
      item :cache, :url => index_path([@site, :cached_page]) do
        item :clear_all, :caption => link_to_cached_pages_clear(@site)
      end
      item :plugins, :url => admin_plugins_path(@site) do
        if @plugin
          item :show, :url => show_path(@plugin)
          item :restore_defaults, :caption => link_to_plugin_restore_defaults(@site, @plugin)
        end
      end
    end
    
    item :users, :url => admin_site_users_path(@site), :branch => :right do
      item :users, :url => admin_site_users_path(@site) do
        item :new, :url => new_admin_site_user_path(@site)
        if @user && !@user.new_record?
          item :show,   :url => admin_site_user_path(@site, @user)
          item :edit,   :url => edit_admin_site_user_path(@site, @user)
          item :delete, :caption => link_to_delete(@user)
        end
      end
    end
  end
end