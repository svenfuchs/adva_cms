module RoutingFilter
  class AdvaLocale < Locale

    def around_generate(*args, &block)
      options = args.extract_options!
      site_locale = options[:site_locale]
      locale = options[:locale]                      # extract the passed :locale option
      locale = I18n.locale if locale.nil?            # default to I18n.locale when locale is nil (could also be false)
      locale = nil unless valid_locale?(locale)      # reset to no locale when locale is not valid

      returning yield do |result|
        if locale && prepend_locale?(locale, site_locale)
          url = result.is_a?(Array) ? result.first : result
          prepend_locale!(url, locale)
        end
      end
    end

    protected

    def prepend_locale?(locale, site_locale)
      self.class.include_default_locale? || !default_locale?(locale, site_locale)
    end

    def default_locale?(locale, site_locale)
      if !site_locale
        locale && locale.to_sym == I18n.default_locale.to_sym
      else
        locale && locale.to_sym == site_locale.to_sym
      end
    end

  end
end