module CacheableFlash
  module TestHelpers
    def flash_cookie
      return {} unless cookies['flash']
      flash = CGI::unescape cookies['flash']
      HashWithIndifferentAccess.new JSON.parse(flash)
    end    
  end
end