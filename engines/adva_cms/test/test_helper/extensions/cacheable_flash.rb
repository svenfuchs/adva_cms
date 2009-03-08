# http://github.com/pivotal/cacheable-flash

# modified the original helper to unescape stuff
module CacheableFlash
  module TestHelpers
    def flash_cookie
      return {} unless cookies['flash']
      flash = CGI::unescape cookies['flash']
      flash = flash ? JSON.parse(flash) : {}
      HashWithIndifferentAccess.new flash
    end
  end
end
ActionController::TestResponse.send :include, CacheableFlash::TestHelpers
