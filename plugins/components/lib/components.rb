module Components #:nodoc:
  def self.render(name, component_args = [], options = {})
    klass, method = name.split('/')
    component = (klass + "_component").camelcase.constantize.new
    component.form_authenticity_token = options[:form_authenticity_token]
    merge_standard_component_options!(component_args, options[:standard_component_options], component.method(method).arity)
    component.logger.debug "Rendering component #{name}"
    component.send(method, *component_args).to_s
  end

  def self.merge_standard_component_options!(args, standard_options, arity)
    if standard_options
      # when the method's arity is positive, it only accepts a fixed list of arguments, so we can't add another.
      args << {} unless args.last.is_a?(Hash) or not arity < 0
      args.last.reverse_merge!(standard_options) if args.last.is_a?(Hash)
    end
  end

  module ActionController
    protected

    # Renders the named component with the given arguments. The component name must indicate both
    # the component class and the class' action.
    #
    # Example:
    #
    #   class UsersController < ApplicationController
    #     def show
    #       render :text => component("users/details", params[:id])
    #     end
    #   end
    #
    # would render:
    #
    #   class UsersComponent < Components::Base
    #     def details(user_id)
    #       "all the important details about the user, nicely marked up"
    #     end
    #   end
    def component(name, *args)
      Components.render(name, args,
        :form_authenticity_token => (form_authenticity_token if protect_against_forgery?),
        :standard_component_options => standard_component_options
      )
    end

    # Override this method on your controller (probably your ApplicationController)
    # to define common arguments for your components. For example, you may always
    # want to provide the current user, in which case you could return {:user =>
    # current_user} from this method.
    #
    # In order to use this, your component actions should accept an options hash
    # as their last argument.
    #
    # I feel like this is a better solution than simply making request and
    # session details directly available to the components.
    def standard_component_options; end
  end

  module ActionView
    # Renders the named component with the given arguments. The component name must indicate both
    # the component class and the class' action.
    #
    # Example:
    #
    #   /app/views/users/show.html.erb
    #
    #     <%= component "users/details", @user.id %>
    #
    # would render:
    #
    #   class UsersComponent < Components::Base
    #     def details(user_id)
    #       "all the important details about the user, nicely marked up"
    #     end
    #   end
    def component(name, *args)
      Components.render(name, args,
        :form_authenticity_token => (form_authenticity_token if protect_against_forgery?),
        :standard_component_options => controller.send(:standard_component_options)
      )
    end
  end
end

ActionController::Base.class_eval do include Components::ActionController end
ActionView::Base.class_eval       do include Components::ActionView       end

