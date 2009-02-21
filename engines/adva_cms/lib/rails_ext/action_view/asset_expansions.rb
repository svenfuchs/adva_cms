require 'action_view/helpers/asset_tag_helper'

module ActionView
  module Helpers
    module AssetTagHelper
      def self.register_stylesheet_expansion(expansions)
        expansions.each do |key, values|
          @@stylesheet_expansions[key] ||= []
          @@stylesheet_expansions[key] += Array(values)
        end
      end

      def self.register_javascript_expansion(expansions)
        expansions.each do |key, values|
          @@javascript_expansions[key] ||= []
          @@javascript_expansions[key] += Array(values)
        end
      end
    end
  end
end