module Menus
  module Admin
    class Users < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:users)

        menu :left, :class => 'left' do
          item :users,    :action => :index, :resource => [@site, :user], :namespace => :'admin_site'
        end
        menu :actions, :class => 'actions' do
          activates object.parent.find(:users)
          item :new, :action => :new, :resource => [@site, :user], :namespace => :'admin_site'
          if @user && !@user.new_record?
            item :show,   :action  => :show,   :resource => @user, :namespace => :'admin_site'
            item :edit,   :action  => :edit,   :resource => @user, :namespace => :'admin_site'
            item :delete, :content => link_to_delete(@user)
          end
        end
      end
    end
  end
end