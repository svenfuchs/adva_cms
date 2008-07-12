require 'cgi'

class Object
  unless method_defined?(:to_param)
    def to_param
      to_s
    end
  end
  
  unless method_defined?(:to_query)
    def to_query(key)
      [CGI.escape(key.to_s), CGI.escape(to_param.to_s)].join('=')
    end
  end
end