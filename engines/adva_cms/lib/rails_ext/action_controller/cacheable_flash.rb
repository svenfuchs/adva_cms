# http://github.com/pivotal/cacheable-flash

require "json"

module CacheableFlash
  def self.included(base)
    base.prepend_around_filter :write_flash_to_cookie
  end

  def write_flash_to_cookie
    yield

    cookie_flash = cookies['flash'] ? JSON.parse(cookies['flash']) : {}

    flash.each do |key, value|
      if cookie_flash[key.to_s].blank?
        cookie_flash[key.to_s] = value
      else
        cookie_flash[key.to_s] << "<br/>#{value}" # TODO should be an array
      end
    end

    cookies['flash'] = cookie_flash.to_json
    flash.clear
  end
end