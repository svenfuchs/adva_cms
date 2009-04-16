module Menus
  module Admin
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
            item :edit,   :action => :edit, :resource => @photo
            item :delete, :content => link_to_delete(@photo)
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
            item :edit,   :action => :edit, :resource => @set
            item :delete, :content => link_to_delete(@set)
          end
        end
      end
    end
  end
end