module Menus
  module Admin
    class Wiki < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:sections)

        menu :left, :class => 'left', :type => Sections::Content
        menu :actions, :class => 'actions' do
          activates object.parent.find(:wikipages)

          item :new, :action => :new, :resource => [@section, :wikipage]
          if @wikipage and !@wikipage.new_record?
            item :edit,   :action => :edit, :resource => @wikipage
            item :delete, :content => link_to_delete(@wikipage)
          end
        end
      end
    end
  end
end