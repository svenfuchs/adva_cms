module ActionController
  module ContextTemplates
    module ActMacro
      def renders_in_context(context, options = {})
        return if renders_in_context?

        include InstanceMethods
        alias_method_chain :render, :context_templates
        
        options[:context] = context
        class_inheritable_writer :context_render_options
        self.context_render_options = options
      end
    
      def renders_in_context?
        included_modules.include?(ActionController::ContextTemplates::InstanceMethods)
      end
    end

    module InstanceMethods
      def render_with_context_templates(options = nil, extra_options = {}, &block)
        unless context_render_templates(options).blank?
          begin
            render_without_context_templates(context_render_templates(options), &block)
          rescue ActionView::MissingTemplate => e
            p e
            render_without_context_templates(options, extra_options, &block)
          end
        else
          render_without_context_templates(options, extra_options, &block)
        end
      end

      protected

        def context_render_templates(options)
          @context_render_templates = begin
            case c = self.class.read_inheritable_attribute(:context_render_options)[:context]
            when Symbol then context = send(c)
            when Proc   then context = c.call(self)
            end
            options ||= {}
            options.update context.template_options(action_name) if context_render?(context, options)
          end
        end

        def context_render?(context, options) # TODO make this more configurable
          !!(context.respond_to?(:template_options) and
             request.path !~ /^\/admin/ and 
             params[:format].nil? || params[:format] == 'html' and
             options.blank? || options.is_a?(Hash) && (options.keys & [:template, :action]).any?)
        end
    end
  end
end

ActionController::Base.send :extend, ActionController::ContextTemplates::ActMacro
