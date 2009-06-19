class UserFormBuilder < ExtensibleFormBuilder
  after :user, :signup_fields do |f|
    render "adva/subscriptions/signup", :f => f
  end
end

module Adva
  module Extensions
    module Newsletter
      module User
        include_into 'User'

        def self.included(target)
          target.class_eval do
            has_many :subscriptions, :dependent => :destroy, :class_name => "Adva::Subscription"
            accepts_nested_attributes_for :subscriptions, :reject_if => lambda { |attributes| attributes['subscribe'] != "1" }
          end
        end
      end
    end

    # FIXME: clashes with Rails' own use of self.inherited (see ActionController::Helpers)
    # module UserController
    #   include_into 'UserController'
    #
    #   def self.included(target)
    #     target.class_eval do
    #       before_filter :set_newsletter_attributes
    #       include InstanceMethods
    #     end
    #   end
    #
    #   module InstanceMethods
    #     protected
    #     def set_newsletter_attributes
    #       @newsletter_attributes = @site.newsletters.published.inject([]) do |newsletter_attributes, newsletter|
    #         newsletter_attributes << returning({}) do |attributes|
    #           attributes[:subscribable_id]   = newsletter.id
    #           attributes[:subscribable_type] = newsletter.class.to_s
    #         end
    #       end
    #     end
    #   end
    # end
  end
end