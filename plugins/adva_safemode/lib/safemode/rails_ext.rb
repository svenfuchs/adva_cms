if defined?(Rails)
  class RequestJail < Safemode::Jail
    allow :request_uri
  end

  module ActionController
    class TestRequest < Request
      class Jail < RequestJail
      end
    end
    class Request < Rack::Request
      class Jail < RequestJail
      end
    end
  end
end
