require "cacheable_flash/test_helpers"

# modified the original helper to unescape stuff
module CacheableFlash
  module TestHelpers
    def flash_cookie
      return {} unless cookies['flash']
      flash = CGI::unescape cookies['flash'].first
      HashWithIndifferentAccess.new JSON.parse(flash)
    end
  end
end
ActionController::TestResponse.send :include, CacheableFlash::TestHelpers

