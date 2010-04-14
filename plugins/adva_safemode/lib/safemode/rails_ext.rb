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

  module ActiveSupport
    class TimeWithZone
      class Jail < Safemode::Jail
        allow %w(blank? duplicable? present?
              _dump asctime ctime day dst? getgm getlocal getutc gmt?
              gmt_offset gmtime gmtoff hash hour httpdate isdst iso8601
              localtime mday min minus_without_duration mon month
              plus_without_duration rfc2822 rfc822 sec strftime succ to_date
              to_datetime to_f to_i tv_sec tv_usec usec utc utc? utc_offset
              wday xmlschema yday year zone to_formatted_s).map(&:to_sym)
      end
    end
  end

  module ActionView
    class Base
      class Jail < Safemode::Jail
        allow :output_buffer, :output_buffer=, :concat
      end
    end
  end
end
