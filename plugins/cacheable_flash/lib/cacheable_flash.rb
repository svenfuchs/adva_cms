module CacheableFlash
  def self.included(base)
    base.after_filter :write_flash_to_cookie
  end

  def write_flash_to_cookie
    cookie_flash = cookies['flash'] ? JSON.parse(cookies['flash']) : {}

    flash.each do |key, value|
      if cookie_flash[key.to_s].blank?
        cookie_flash[key.to_s] = value
      else
        cookie_flash[key.to_s] << "<br/>#{value}"
      end
    end

    cookies['flash'] = cookie_flash.to_json
    
    # JMH -- removed this. why not allow the receiving view to decide which type of flash msg to use?    
    # Sv -- put it back for now. it results in all flash messages being displayed twice
    flash.clear 
  end
end
