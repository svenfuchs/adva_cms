require 'safemode'
require 'erb'

module ActionView
  module TemplateHandlers
    class SafeErb < TemplateHandler
      include Compilable rescue nil # does not exist prior Rails 2.1
      extend SafemodeHandler
      
      def self.line_offset
        0
      end

      def compile(template)
        # Rails 2.0 passes the template source, while Rails 2.1 passes the
        # template instance
        src = template.respond_to?(:source) ? template.source : template
        filename = template.filename rescue nil
        
        code = ::ERB.new(src, nil, @view.erb_trim_mode).src
        code.gsub!('\\','\\\\\\') # backslashes would disappear in compile_template/modul_eval, so we escape them
      
        <<-CODE 
          handler = ActionView::TemplateHandlers::SafeHaml
          assigns = handler.valid_assigns(@template.assigns)
          methods = handler.delegate_methods(self)
          code = %Q(#{code});
          
          box = Safemode::Box.new(self, methods, #{filename.inspect}, 0)
          box.eval(code, assigns, local_assigns, &lambda{ yield })        
        CODE
      end
    end
  end
end
