module Menus
  class Sections < Menu::Menu
    define do
      id :sections
      @site.sections.each { |section| item section.title, :action => :show, :resource => section }
    end
  end
  
  module Admin
    class Sites < Menu::Group
      define do
        namespace :admin
        breadcrumb :site, :content => link_to_show(@site.name, @site) if @site && !@site.new_record?

        menu :left, :class => 'left' do
          item :sites, :action => :index, :resource => :site if Site.multi_sites_enabled
          if @site && !@site.new_record?
            item :overview,    :action => :show,  :resource => @site
            item :sections,    :action => :index, :resource => [@site, :section], :type => Menu::SectionsMenu, :populate => lambda { @site.sections }
            item :comments,    :action => :index, :resource => [@site, :comment]
            item :newsletters, :action => :index, :resource => [@site, :newsletter]
            item :assets,      :action => :index, :resource => [@site, :asset]
          end
        end

        menu :right, :class => 'right' do
          item :themes,   :action => :index, :resource => [@site, :theme]
          item :settings, :action => :edit,  :resource => @site
          item :users,    :action => :index, :resource => [@site, :user]
        end if @site && !@site.new_record?
      end

      class Main < Menu::Group
        define do
          id :main
          parent Sites.new.build(scope).find(:sites)
          menu :right, :class => 'right' do
            item :new, :action => :new, :resource => :site
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
            item :delete, :action => :delete, :resource => @section
          end
        else
          menu :left, :class => 'left' do
            item :sections, :action => :index, :resource => [@site, :section]
          end
          menu :right, :class => 'right' do
            activates object.parent.find(:sections)
            item :new, :action => :new, :resource => [@site, :section]
          end
        end
      end

      class Content < Menu::Menu
        define do
          type = @section.class.content_type.underscore
          item :section, :content => content_tag(:h4, "#{@section.title}:")
          item type.pluralize.to_sym, :action => :index, :resource => [@section, type]
          item :categories, :action => :index, :resource => [@section, :category]
          item :settings,   :action => :edit,  :resource => @section
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
          item :new, :action => :new, :resource => [@section, :article]
          if @article and !@article.new_record?
            # article show link is also a preview link and directs to frontend, if we use :action 
            # and :resource, the link generated would suggest backend show action instead
            item :show,   :content  => link_to_show(@article, :cl => content_locale, :namespace => nil)
            item :edit,   :action   => :edit,   :resource => @article
            item :delete, :action   => :delete, :resource => @article
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
          item :new, :action => :new, :resource => [@section, :category]
          if @category && !@category.new_record?
            item :edit,   :action => :edit,   :resource => @category
            item :delete, :action => :delete, :resource => @category
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
          item :new, :action => :new, :resource => [@section, :calendar_event]
          if @event and !@event.new_record?
            item :edit,   :action => :edit,   :resource => @event
            item :delete, :action => :delete, :resource => @event
          end
        end
      end
    end

    class Comments < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:comments)

        menu :left, :class => 'left' do
          item :comments, :action => :index, :resource => [@site, :comment]
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
          item :topics,   :action => :index, :resource => [@section, :topic]
          item :boards,   :action => :index, :resource => [@section, :board]
          item :settings, :action => :edit,  :resource => @section
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
          item :new, :action => :new, :resource => [@section, :board]
          if @board and !@board.new_record?
            item :edit,   :action => :edit,   :resource => @board
            item :delete, :action => :delete, :resource => @board
          end
        end
      end
    end

    class AlbumBase < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left' do
          item :section,  :content => content_tag(:h4, "#{@section.title}:")
          item :photos,   :action => :index, :resource => [@section, :photo]
          item :sets,     :action => :index, :resource => [@section, :set]
          item :settings, :action => :edit, :resource => @section
        end
      end
    end

    class Photos < AlbumBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:photos)
          item :new, :action => :new, :resource => [@section, :photo]
          if @photo and !@photo.new_record?
            item :edit,   :action => :edit,   :resource => @photo
            item :delete, :action => :delete, :resource => @photo
          end
        end
      end
    end

    class Sets < AlbumBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:sets)
          item :new, :action => :new, :resource => [@section, :set]
          if @set and !@set.new_record?
            item :edit,   :action => :edit,   :resource => @set
            item :delete, :action => :delete, :resource => @set
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

          item :new, :action => :new, :resource => [@section, :wikipage]
          if @wikipage and !@wikipage.new_record?
            item :edit,   :action => :edit,   :resource => @wikipage
            item :delete, :action => :delete, :resource => @wikipage
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
          item :new, :action => :new, :resource => [@site, :asset]
          if @asset and !@asset.new_record?
            item :edit,   :action => :edit,   :resource => @asset
            item :delete, :action => :delete, :resource => @asset
          end
        end
      end
    end

    class NewsletterBase < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:newsletters)
        menu :left, :class => 'left' do
          item :newsletters, :action => :index, :resource => [@site, :newsletter]
          if @newsletter && !@newsletter.new_record?
            item :issues,        :action => :index, :resource => [@newsletter, :issue]
            item :subscriptions, :action => :index, :resource => [@newsletter, :subscription]
          end
        end
      end
    end

    class Newsletter < NewsletterBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:newsletters)
          item :new, :action => :new, :resource => [@site, :newsletter]
          if @newsletter and !@newsletter.new_record?
            item :edit,   :action => :edit,   :resource => @newsletter
            item :delete, :action => :delete, :resource => @newsletter
          end
        end
      end
    end

    class Issues < NewsletterBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:issues)
          item :new, :action => :new, :resource => [@newsletter, :issue]
          if @issue and !@issue.new_record?
            item :view,   :action => :show,   :resource => @issue
            item :edit,   :action => :edit,   :resource => @issue
            item :delete, :action => :delete, :resource => @issue
          end
        end
      end
    end

    class NewsletterSubscriptions < NewsletterBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:subscriptions)
          item :new, :action => :new, :resource => [@newsletter, :subscription]
        end
      end
    end

    class ThemesBase < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:themes)
        menu :left, :class => 'left' do
          item :themes, :action => :index, :resource => [@site, :theme]
          item :files,  :action => :index, :resource => [@theme, :'theme/file'] if @theme && !@theme.new_record?
        end
      end
    end

    class Themes < ThemesBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:themes)
          item :new,    :action => :new, :resource => [@site, :theme]
          item :import, :url    => import_admin_themes_path(@site)
          if @theme and !@theme.new_record?
            item :edit, :action => :edit, :resource => @theme
            if @theme.active?
              item :deactivate, :content => link_to_deactivate_theme(@theme)
            else
              item :activate,   :content => link_to_activate_theme(@theme)
            end
            item :download, :url    => export_admin_theme_path(@site, @theme)
            item :delete,   :action => :delete, :resource => @theme
          end
        end
      end
    end

    class ThemeFiles < ThemesBase
      define do
        menu :right, :class => 'right' do
          activates object.parent.find(:files)
          item :new,    :action => :new, :resource => [@theme, :'theme/file']
          item :upload, :url    => import_admin_theme_files_path(@site, @theme.id)
          if @file and !@file.new_record?
            item :edit,   :url      => admin_theme_file_path(@site, @theme.id, @file)
            item :delete, :content  => link_to_delete_theme_file(@file)
          end
        end
      end
    end

    class Settings < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:settings)
        menu :left, :class => 'left' do
          item :settings, :action => :edit,  :resource => @site
          item :cache,    :action => :index, :resource => [@site, :cached_page]
          item :plugins,  :url    => admin_plugins_path(@site)
        end
        menu :right, :class => 'right' do
          item :delete,   :action => :delete, :resource => @site
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
            item :show,             :action  => :show, :resource => @plugin
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
          item :users,    :action => :index, :resource => [@site, :user], :namespace => :'admin_site'
        end
        menu :right, :class => 'right' do
          activates object.parent.find(:users)
          item :new, :action => :new, :resource => [@site, :user], :namespace => :'admin_site'
          if @user && !@user.new_record?
            item :show,   :action => :show,   :resource => @user, :namespace => :'admin_site'
            item :edit,   :action => :edit,   :resource => @user, :namespace => :'admin_site'
            item :delete, :action => :delete, :resource => @user, :namespace => :'admin_site'
          end
        end
      end
    end
  end
end
