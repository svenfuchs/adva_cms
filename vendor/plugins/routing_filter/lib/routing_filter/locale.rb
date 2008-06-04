module RoutingFilter
  class Locale < Base
    @@default_locale = 'en'
    cattr_reader :default_locale
    
    # remove the locale from the beginning of the path, pass the path
    # to the given block and set it to the resulting params hash
    def around_recognition(route, path, env, &block)
      locale = nil
      path.sub! %r(^/([a-zA-Z]{2})(?=/|$)) do locale = $1; '' end
      returning yield(path, env) do |params|
        params[:locale] = locale if locale
      end
    end

    # prepend the current locale to the path if it's not the default locale
    def after_generate(base, result, *args)
      locale = base.instance_variable_get(:@locale)
      result.replace "/#{locale}#{result}" if locale and locale != @@default_locale
      # TODO won't work with full urls, stupid
    end
  end
end