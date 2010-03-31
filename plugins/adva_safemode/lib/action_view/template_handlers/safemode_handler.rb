module ActionView
  module TemplateHandlers
    module SafemodeHandler

      def valid_assigns(assigns)
        assigns.reject { |key, value| skip_assigns.include?(key) }
      end

      def delegate_methods(view)
        [ :render, :params, :flash ] +
        helper_methods(view) +
        ActionController::Routing::Routes.named_routes.helpers
      end

      def helper_methods(view)
        view.class.included_modules.collect {|m| m.instance_methods(false) }.flatten.map(&:to_sym)
      end

      def skip_assigns
        # [ "_cookies", "_flash", "_headers", "_params", "_request",
        #   "_response", "_session", "before_filter_chain_aborted",
        #   "ignore_missing_templates", "logger", "request_origin",
        #   "template", "template_class", "url", "variables_added",
        #   "view_paths" ]
        #
        # TODO validate whether the list below is complete or not. above is the previous list

        [ "@_request", "@controller", "@_current_render",
          "@assigns_added", "@real_format", "@_first_render",
          "@template_format", "@assigns", "@template",
          "@view_paths", "@helpers"]
      end
    end
  end
end
