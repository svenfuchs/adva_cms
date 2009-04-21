module Menus
  module Admin
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
        menu :actions, :class => 'actions' do
          activates object.parent.find(:themes)
          item :new,    :action => :new, :resource => [@site, :theme]
          item :import, :url    => import_admin_themes_path(@site)
          if @theme and !@theme.new_record?
            item :edit, :action => :edit, :resource => @theme
            if @theme.active?
              item :deactivate, :content => link_to_deactivate_theme(@theme)
            else
              item :activate, :content => link_to_activate_theme(@theme)
            end
            item :download, :url => export_admin_theme_path(@site, @theme)
            item :delete,   :content => link_to_delete(@theme)
          end
        end
      end
    end

    class ThemeFiles < ThemesBase
      define do
        menu :actions, :class => 'actions' do
          activates object.parent.find(:files)
          item :new,    :action => :new, :resource => [@theme, :'theme/file']
          item :upload, :url    => import_admin_theme_files_path(@site, @theme.id)
          if @file and !@file.new_record?
            item :edit,   :url => admin_theme_file_path(@site, @theme.id, @file)
            item :delete, :content  => link_to_delete_theme_file(@file)
          end
        end
      end
    end
  end
end