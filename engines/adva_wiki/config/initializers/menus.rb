module Menus
  module Admin
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
  end
end