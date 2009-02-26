require 'theme_support/action_controller'
require 'theme_support/active_record'
# require 'theme_support/action_mailer'
require 'theme_support/asset_tag_helper'

module ThemeSupport
  class TemplateTypeError < StandardError
    def initialize(template, allowed_types)
      super "Template '#{template}' must be one of these types: #{allowed_types.join(', ')}"
    end
  end
end
