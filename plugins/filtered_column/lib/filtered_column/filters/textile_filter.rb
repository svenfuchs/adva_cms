module FilteredColumn
  module Filters
    class TextileFilter < Base
      def self.filter(text)
        Object.const_defined?("RedCloth") ? RedCloth.new(text).to_html : text
      end
      
      def self.escape(text)
        %(<notextile>#{text}</notextile>)
      end
    end
  end
end