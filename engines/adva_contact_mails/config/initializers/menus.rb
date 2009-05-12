module Menus
  module Admin
    class ContactMailsBase < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:contact_mails)
        menu :left, :class => 'left' do
          item :contact_mails, :action => :index, :resource => [@site, :contact_mails]
        end
      end
    end
    
    class ContactMails < ContactMailsBase
      define do
        menu :actions, :class => 'actions' do
          if @contact_mail and !@contact_mail.new_record?
            item :show,   :action => :show, :resource => @contact_mail
            item :delete, :content => link_to_delete(@contact_mail)
          end
        end
      end
    end
  end
end