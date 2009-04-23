module Menus
  module Admin
    class Users < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:users)

        menu :left, :class => 'left' do
          item :users, :action => :index, :resource => [@site, :user]
        end
        menu :actions, :class => 'actions' do
          activates object.parent.find(:users)
          item :new, :action => :new, :resource => [@site, :user]
          if @user && !@user.new_record?
            item :show,   :url => admin_user_path(@site, @user)
            item :edit,   :url => edit_admin_user_path(@site, @user)
            # item :show,   :action  => :show, :resource => @user
            # item :edit,   :action  => :edit, :resource => @user
            item :delete, :content => link_to_delete(@user)
          end
        end
      end
    end
  end
end