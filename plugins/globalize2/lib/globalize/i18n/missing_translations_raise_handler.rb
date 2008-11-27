# A simple exception handler that behaves like the default exception handler
# but also raises on missing translations.
#
# Useful for identifying missing translations during testing.
# 
# E.g. 
#
#   require 'globalize/i18n/missing_translations_raise_handler
#   I18n.exception_handler = :missing_translations_raise_handler

module I18n
  @@missing_translations_logger = nil
  
  class << self
    def missing_translations_raise_handler(exception, locale, key, options)
      raise exception
    end
  end
end
