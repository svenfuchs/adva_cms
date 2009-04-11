module Menus
  module Admin
    class Sites < Menu::Group
      define do
        breadcrumb :site, :content => link_to_show(@site.name, @site)

        menu :left, :class => 'left' do
          item :sites, :url => admin_sites_path if Site.multi_sites_enabled
          if @site && !@site.new_record?
            item :overview,    :url => admin_site_path(@site)
            item :sections,    :url => index_path([@site, :section]), :type => Menu::SectionsMenu, :populate => lambda { @site.sections }
            item :newsletters, :url => index_path([@site, :newsletter])
            item :assets,      :url => admin_assets_path(@site)
          end
        end

        menu :right, :class => 'right' do
          item :themes,      :url => index_path([@site, :theme])
          item :settings,    :url => edit_admin_site_path(@site)
          item :users,       :url => admin_site_users_path(@site)
        end if @site && !@site.new_record?
      end

      class Main < Menu::Group
        define do
          id :main
          parent Sites.new.build(scope).find(:sites)
          menu :right, :class => 'right' do
            item :new, :url => new_path([:site])
          end
        end
      end
    end

    class Sections < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        if @section and !@section.new_record?
          type = "Menus::Admin::Sections::#{@section.type}".constantize rescue Content
          menu :left, :class => 'left', :type => type
          menu :right, :class => 'right' do
            item :delete, :content => link_to_delete(@section)
          end
        else
          menu :left, :class => 'left' do
            item :sections, :url => index_path([@site, :section])
          end
          menu :right, :class => 'right' do
            activates object.parent.find(:sections)
            item :new, :url => new_path([@site, :section])
          end
        end
      end

      class Content < Menu::Menu
        define do
          type = @section.class.content_type.underscore
          item :section, :content => content_tag(:h4, "#{@section.title}:")
          item type.pluralize.to_sym, :url => index_path([@section, type])
          item :categories, :url => index_path([@section, :category])
          item :settings, :url => edit_path(@section)
        end
      end
    end

    class Articles < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left', :type => Sections::Content
        menu :right, :class => 'right' do
          activates object.parent.find(:articles)
          item :new, :url => new_path([@section, :article])
          if @article and !@article.new_record?
            item :edit,   :url => edit_path(@article)
            item :delete, :content => link_to_delete(@article)
          end
        end
      end
    end

    class Categories < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left', :type => Sections::Content
        menu :right, :class => 'right' do
          activates object.parent.find(:categories)
          item :new, :url => new_path([@section, :category])
          if @category && !@category.new_record?
            item :edit, :url => edit_path(@category)
            item :delete, :content => link_to_delete(@category)
          end
        end
      end
    end

    class Calendar < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left', :type => Sections::Content
        menu :right, :class => 'right' do
          activates object.parent.find(:calendar_events)
          item :new, :url => new_path([@section, :calendar_event])
          if @event and !@event.new_record?
            item :edit,   :url => edit_path(@event)
            item :delete, :content => link_to_delete(@event)
          end
        end
      end
    end

    class Topics < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left', :type => Sections::Forum
      end
    end

    class Sections
      class Forum < Menu::Menu
        define do
          item :section, :content => content_tag(:h4, "#{@section.title}:")
          item :topics, :url => index_path([@section, :topic])
          item :boards, :url => index_path([@section, :board])
          item :settings, :url => edit_path(@section)
        end
      end
    end

    class Boards < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left', :type => Sections::Forum
        menu :right, :class => 'right'do
          activates object.parent.find(:boards)
          item :new, :url => new_path([@section, :board])
          if @board and !@board.new_record?
            item :edit,   :url => edit_path(@board)
            item :delete, :content => link_to_delete(@board)
          end
        end
      end
    end

    class AlbumBase < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left' do
          item :section, :content => content_tag(:h4, "#{@section.title}:")
          item :photos, :url => index_path([@section, :photo])
          item :sets, :url => index_path([@section, :set])
          item :settings, :url => edit_path(@section)
        end
      end
    end

    class Photos < AlbumBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:photos)
          item :new, :url => new_path([@section, :photo])
          if @photo and !@photo.new_record?
            item :edit,   :url => edit_path(@photo)
            item :delete, :content => link_to_delete(@photo)
          end
        end
      end
    end

    class Sets < AlbumBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:sets)
          item :new, :url => new_path([@section, :set])
          if @set and !@set.new_record?
            item :edit,   :url => edit_admin_set_path(@site, @section, @set)
            item :delete, :content => link_to_delete_set(@set)
          end
        end
      end
    end

    class Wiki < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left', :type => Sections::Content
        menu :right, :class => 'right' do
          activates object.parent.find(:wikipages)

          item :new, :url => new_path([@section, :wikipage])
          if @wikipage and !@wikipage.new_record?
            item :edit,   :url => edit_path(@wikipage)
            item :delete, :content => link_to_delete(@wikipage)
          end
        end
      end
    end

    class Assets < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:assets)

        menu :left, :class => 'left' do
          item :assets, :url => admin_assets_path(@site)
        end

        menu :right, :class => 'right' do
          activates object.parent.find(:assets)
          item :new, :url => new_path([@site, :asset])
          if @asset and !@asset.new_record?
            item :edit,   :url => edit_path(@asset)
            item :delete, :content => link_to_delete(@asset)
          end
        end
      end
    end

    class NewsletterBase < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:newsletters)
        menu :left, :class => 'left' do
          item :newsletters, :url => index_path([@site, :newsletter])
          item :issues,      :url => index_path([@newsletter, :issue]) if @newsletter && !@newsletter.new_record?
        end
      end
    end

    class Newsletter < NewsletterBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:newsletters)
          item :new, :url => new_path([@site, :newsletter])
          if @newsletter and !@newsletter.new_record?
            item :edit,   :url => edit_path(@newsletter)
            item :delete, :content => link_to_delete(@newsletter)
          end
        end
      end
    end

    class Issues < NewsletterBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:issues)
          item :new, :url => new_path([@newsletter, :issue])
          if @issue and !@issue.new_record?
            item :view,   :url => show_path(@issue)
            item :edit,   :url => edit_path(@issue)
            item :delete, :content => link_to_delete(@issue)
          end
        end
      end
    end

    class ThemesBase < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:themes)
        menu :left, :class => 'left' do
          item :themes, :url => index_path([@site, :theme])
          item :files,  :url => index_path([@theme, :'theme/file']) if @theme && !@theme.new_record?
        end
      end
    end

    class Themes < ThemesBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:themes)
          item :new, :url => new_path([@site, :theme])
          if @theme and !@theme.new_record?
            item :edit,   :url => edit_path(@theme)
            if @theme.active?
              item :deactivate, :content => link_to_deactivate_theme(@theme)
            else
              item :activate, :content => link_to_activate_theme(@theme)
            end
            item :download, :url => export_admin_theme_path(@site, @theme)
            item :delete, :content => link_to_delete(@theme)
          end
        end
      end
    end

    class ThemeFiles < ThemesBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:files)
          item :new, :url => new_path([@theme, :'theme/file'])
          item :upload, :url => import_admin_theme_files_path(@site, @theme.id)
          if @file and !@file.new_record?
            item :edit,   :url => admin_theme_file_path(@site, @theme.id, @file)
            item :delete, :content => link_to_delete_theme_file(@file)
          end
        end
      end
    end

    class Settings < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:settings)
        menu :left, :class => 'left' do
          item :settings, :url => edit_path(@site)
          item :cache,    :url => index_path([@site, :cached_page])
          item :plugins,  :url => admin_plugins_path(@site)
        end
      end
    end

    class CachedPages < Settings
      define do
        menu :right, :class => 'right' do
          item :clear_all, :content => link_to_clear_cached_pages(@site)
        end
      end
    end

    class Plugins < Settings
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:plugins)
          if @plugin
            item :show, :url => show_path(@plugin)
            item :restore_defaults, :content => link_to_restore_plugin_defaults(@site, @plugin)
          end
        end
      end
    end

    class Users < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:users)

        menu :left, :class => 'left' do
          item :users, :url => admin_site_users_path(@site)
        end
        menu :right, :class => 'right' do
          activates object.parent.find(:users)
          item :new, :url => new_admin_site_user_path(@site)
          if @user && !@user.new_record?
            item :view,   :url => admin_site_user_path(@site, @user)
            item :edit,   :url => edit_admin_site_user_path(@site, @user)
            item :delete, :content => link_to_delete(@user)
          end
        end
      end
    end
  end
end
