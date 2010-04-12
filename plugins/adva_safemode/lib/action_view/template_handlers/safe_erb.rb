require 'safemode'
require 'erb'

module ActionView
  module TemplateHandlers
    class SafeErb < TemplateHandler
      extend SafemodeHandler
      include Compilable

      def self.line_offset
        0
      end

      def compile(template)
        src = template.source
        filename = template.filename
        erb_trim_mode = ActionView::TemplateHandlers::ERB.erb_trim_mode

        code = ::ERB.new("<% __in_erb_template=true %>#{src}", nil, erb_trim_mode, '@output_buffer').src
        # Ruby 1.9 prepends an encoding to the source. However this is
        # useless because you can only set an encoding on the first line
        RUBY_VERSION >= '1.9' ? src.sub(/\A#coding:.*\n/, '') : src

        code.gsub!('\\','\\\\\\') # backslashes would disappear in compile_template/modul_eval, so we escape them

        code = <<-CODE
          handler = ActionView::TemplateHandlers::SafeErb
          assigns = {}
          handler.valid_assigns(instance_variables).each do |var|
            assigns[var[1,var.length]] = instance_variable_get(var)
          end
          methods = handler.delegate_methods(self)

          code = %Q(#{code});

          box = Safemode::Box.new(self, methods, #{filename.inspect}, 0)
          box.eval(code, assigns, local_assigns, &lambda{ |*args| yield(*args) })
        CODE
        # puts code
        code
      end
    end
  end
end
