module ActionView
  class Template    
    def initialize(view, path, use_full_path, locals = {})
      @view = view
      @finder = @view.finder

      # Clear the forward slash at the beginning if exists
      @path = use_full_path ? path.sub(/^\//, '') : path
      @view.first_render ||= @path
      @source = nil # Don't read the source until we know that it is required
      set_extension_and_file_name(use_full_path)

      @locals = locals || {}
      @handler = self.class.handler_class_for_template(self).new(@view)
    end
  
    def self.register_template_handler(extension, klass, options = {})
      @@template_handlers[extension.to_sym] = options.update(:class => klass)
      ActionView::TemplateFinder.update_extension_cache_for(extension.to_s)
    end

    def self.handler_class_for_template(template)
      if template.extension && handler = @@template_handlers[template.extension.to_sym]
        if handler.is_a? Hash
          return handler[:class] if eval_handler_conditions(template, handler)
        else
          return handler
        end
      end
      @@default_template_handlers      
    end
    
    def self.eval_handler_conditions(template, handler)
      [:path, :filename].each do |type|
        return false if handler[type] and handler[type] !~ template.send(type)
      end
      true
    end
  end
end
