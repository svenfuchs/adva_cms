module Menus
  module Admin
    class Assets < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:assets)

        menu :left, :class => 'left' do
          item :assets, :url => admin_assets_path(@site)
        end

        menu :actions, :class => 'actions' do
          activates object.parent.find(:assets)
          item :new, :action => :new, :resource => [@site, :asset]
          if @asset and !@asset.new_record?
            item :edit,   :action => :edit,   :resource => @asset
            item :delete, :content => link_to_delete(@asset)
          end
        end
      end
    end
  end
end