module Menus
  module Admin
    class Photos < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left', :type => Sections::Album

        menu :actions, :class => 'actions' do
          activates object.parent.find(:photos)
          item :new, :action => :new, :resource => [@section, :photo]
          if @photo and !@photo.new_record?
            item :edit,   :action => :edit, :resource => @photo
            item :delete, :content => link_to_delete(@photo)
          end
        end
      end
    end

    class Sections
      class Album < Menu::Menu
        define do
          item :section, :content => content_tag(:h4, "#{@section.title}:")
          item :photos,   :action => :index, :resource => [@section, :photo]
          item :sets,   :action => :index, :resource => [@section, :set]
          item :settings, :action => :edit,  :resource => @section
        end
      end
    end

    class Sets < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left', :type => Sections::Album
        menu :actions, :class => 'actions'do
          activates object.parent.find(:set)
          item :new, :action => :new, :resource => [@section, :set]
          if @set and !@set.new_record?
            item :edit,   :action => :edit, :resource => @set
            item :delete, :content => link_to_delete(@set)
          elsif !@set and @section.sets.size > 1
            item :reorder, :content => link_to_index(:'adva.links.reorder', [@section, :set], :id => 'reorder_sets', :class => 'reorder')
          end
        end
      end
    end
  end
end