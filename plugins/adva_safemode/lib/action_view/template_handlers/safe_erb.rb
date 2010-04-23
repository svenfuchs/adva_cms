require 'safemode'
require 'erb'

module ActionView
  module TemplateHandlers
    class SafeErb < TemplateHandler
      include Compilable
      extend SafemodeHandler

      def self.line_offset
        0
      end

      def compile(template)
        src = template.source
        filename = template.filename
        erb_trim_mode = ActionView::TemplateHandlers::ERB.erb_trim_mode

        erb_code = ::ERB.new("<% __in_erb_template=true %>#{src}", nil, erb_trim_mode, 'self.output_buffer').src
        # Ruby 1.9 prepends an encoding to the source. However this is
        # useless because you can only set an encoding on the first line
        RUBY_VERSION >= '1.9' ? src.sub(/\A#coding:.*\n/, '') : src

        Safemode::Boxes[filename] = Safemode::Box.new(erb_code, filename, 0)

        boxed_erb = <<-CODE
          handler = ActionView::TemplateHandlers::SafeErb
          assigns = {}
          handler.valid_assigns(instance_variables).each do |var|
            assigns[var[1,var.length]] = instance_variable_get(var)
          end
          methods = handler.delegate_methods( self.controller.master_helper_module.instance_methods )

          box = Safemode::Boxes[#{filename.inspect}]
          box.eval(self, methods, assigns, local_assigns, &lambda{ |*args| yield(*args) })
        CODE
        # for debugging purposes (or for those curious enough to endure compiled ERB)
        # puts "ERB CODE OF #{filename}"
        # puts erb_code
        # puts ""
        # puts "JAILED CODE OF #{filename}"
        # puts Safemode::Boxes[filename].instance_variable_get('@code')
        boxed_erb
      end
    end
  end
end
