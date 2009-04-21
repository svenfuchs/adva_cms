module Menus
  module Admin
    class Calendar < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left', :type => Sections::Content
        menu :actions, :class => 'actions' do
          activates object.parent.find(:calendar_events)
          item :new, :action => :new, :resource => [@section, :calendar_event]
          if @event and !@event.new_record?
            item :edit,   :action => :edit,   :resource => @event
            item :delete, :content => link_to_delete(@event)
          end
        end
      end
    end
  end
end