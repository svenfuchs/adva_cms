module Menus
  module Admin
    class NewsletterBase < Menu::Group
      define do
        id :main
        parent Sites.new.build(scope).find(:newsletters)
        menu :left, :class => 'left' do
          item :newsletters, :action => :index, :resource => [@site, "Adva::Newsletter"]
          if @newsletter && !@newsletter.new_record?
            item :issues,        :action => :index, :resource => [@newsletter, "Adva::Issue"]
            item :subscriptions, :action => :index, :resource => [@newsletter, "Adva::Subscription"]
          end
        end
      end
    end

    class Newsletters < NewsletterBase
      define do
        menu :actions, :class => 'actions' do
          activates object.parent.find(:newsletters)
          item :new, :action => :new, :resource => [@site, "Adva::Newsletter"]
          if @newsletter and !@newsletter.new_record?
            item :edit,   :action => :edit,   :resource => @newsletter
            item :delete, :content => link_to_delete(@newsletter)
          end
        end
      end
    end

    class Issues < NewsletterBase
      define do
        breadcrumb :newsletter, :content => link_to(@newsletter.title, admin_adva_issues_path(@site, @newsletter)) if @newsletter && !@newsletter.new_record?

        menu :actions, :class => 'actions' do
          activates object.parent.find(:issues)
          item :new, :action => :new, :resource => [@newsletter, "Adva::Issue"]
          if @issue and !@issue.new_record?
            item :show,   :action => :show, :resource => @issue
            item :edit,   :action => :edit, :resource => @issue
            item :delete, :content => link_to_delete(@issue)
          end
        end
      end
    end

    class NewsletterSubscriptions < NewsletterBase
      define do
        breadcrumb :newsletter, :content => link_to(@newsletter.title, admin_adva_issues_path(@site, @newsletter)) if @newsletter && !@newsletter.new_record?

        menu :actions, :class => 'actions' do
          activates object.parent.find(:subscriptions)
          item :new, :action => :new, :resource => [@newsletter, "Adva::Subscription"]
        end
      end
    end
  end
end
