module ActionView
  module TemplateHandlers
    module SafemodeHandler

      def valid_assigns(assigns)
        assigns.reject { |key, value| skip_assigns.include?(key) }
      end

      def delegate_methods(view)
        dm = [ :render, :params, :flash, :h, :html_escape ]
        dm += [ :request ]
        dm += helper_methods(view.class)
        dm += view.controller.master_helper_module.instance_methods
        dm += ActionController::Routing::Routes.named_routes.helpers
        dm.flatten.map(&:to_sym).uniq
      end

      def helper_methods(view_class)
        view_class.included_modules.collect do |m|
          m.instance_methods(false) + helper_methods(m)
        end
      end

      def skip_assigns
        [ "@_cookies", "@_current_render", "@_first_render", "@_flash",
          "@_headers", "@_params", "@_request", "@_response", "@_session",
          "@assigns", "@assigns_added", "@before_filter_chain_aborted",
          "@controller", "@helpers", "@ignore_missing_templates", "@logger",
          "@real_format", "@request_origin", "@template", "@template_class",
          "@template_format", "@url", "@variables_added", "@view_paths" ]
      end
    end
  end
end
