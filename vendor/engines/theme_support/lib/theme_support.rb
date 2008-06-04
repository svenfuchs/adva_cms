require 'theme_support/action_view'
require 'theme_support/action_controller'
require 'theme_support/active_record'
# require 'theme_support/action_mailer'

module ThemeSupport
  class TemplateTypeError < StandardError
    def initialize(template, allowed_types)
      super "Template '#{template}' must be one of these types: #{allowed_types.join(', ')}"
    end
  end
end  
  