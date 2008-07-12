module Shield
  module Spam
    class Template
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::FormHelper
      include ActionView::Helpers::FormTagHelper

      def initialize(template_text)
        @template_text = ERB.new(template_text)
      end

      def render(context)
        context.each_pair do |key, value|
          instance_variable_set("@#{key}", value)
        end

        @template_text.result(binding)
      end
    end
  end
end