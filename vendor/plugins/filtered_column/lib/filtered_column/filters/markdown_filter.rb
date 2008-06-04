require 'bluecloth'
module FilteredColumn
  module Filters
    class MarkdownFilter < Base
      def self.filter(text)
        Object.const_defined?("BlueCloth") ? BlueCloth.new(text.gsub(%r{</?notextile>}, '')).to_html : text
      end
    end
  end
end