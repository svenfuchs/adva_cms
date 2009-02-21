module ActionController
  module ContextTemplates
    module ActMacro
      def renders_in_context(context, options = {})
        return if renders_in_context?

        include InstanceMethods
        alias_method_chain :render, :context_templates
        alias_method_chain :pick_layout, :context_templates
        
        options[:context] = context
        class_inheritable_accessor :context_render_config
        self.context_render_config = options
      end
    
      def renders_in_context?
        included_modules.include?(ActionController::ContextTemplates::InstanceMethods)
      end
    end

    module InstanceMethods
      def render_with_context_templates(options = nil, extra_options = {}, &block)
        with_context_templates(:template, options) do |options|
          render_without_context_templates(options, extra_options, &block)
        end
      end
      
      def pick_layout_with_context_templates(options)
        with_context_templates(:layout, options) do |options|
          pick_layout_without_context_templates(options)
        end
      end

      protected
      
        def with_context_templates(type, options, &block)
          if context_render?(options) and template = context_render_option(type)
            begin
              return yield((options || {}).merge(type => template))
            rescue ActionView::MissingTemplate => e
              Rails.logger.info("can not find custom #{type} #{template.inspect}")
            end
          end
          yield(options)
        end

        def context_render_option(type)
          options = context_render_options
          options[type] if options
        end

        def context_render_options
          @_context_render_options = begin
            case c = self.class.context_render_config[:context]
            when Symbol then context = send(c)
            when Proc   then context = c.call(self)
            end
            context.template_options(action_name) if context.respond_to?(:template_options)
          end
        end

        def context_render?(options) # TODO make this more configurable
          !!(request.path !~ /^\/admin/ and 
             params[:format].nil? || params[:format] == 'html' and
             options.blank? || options.is_a?(Hash) && (options.keys & [:template, :action]).any?)
        end
    end
  end
end

ActionController::Base.send :extend, ActionController::ContextTemplates::ActMacro
