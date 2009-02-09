module Webrat
  class Session
    def current_host
      URI.parse(current_url).host || @context.host || "www.example.com"
    end

    def response_location_host
      URI.parse(response_location).host || @context.host || "www.example.com"
    end
  end
end