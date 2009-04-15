module Menus
  module Admin
    class Comments < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:comments)

        menu :left, :class => 'left' do
          item :comments, :action => :index, :resource => [@site, :comment]
        end
      end
    end
  end
end