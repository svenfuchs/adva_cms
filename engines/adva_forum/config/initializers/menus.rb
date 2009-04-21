module Menus
  module Admin
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
        menu :actions, :class => 'actions'do
          activates object.parent.find(:boards)
          item :new, :action => :new, :resource => [@section, :board]
          if @board and !@board.new_record?
            item :edit,   :action => :edit, :resource => @board
            item :delete, :content => link_to_delete(@board)
          end
        end
      end
    end
  end
end