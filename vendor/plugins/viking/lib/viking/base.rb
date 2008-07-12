module Viking
  
  class Base
    
    attr_accessor :options

    def initialize(options)
      self.options = options
    end

    def verified?
    end

    def check_article(options={})
    end

    def check_comment(options={})
    end
  
    def mark_as_spam(options={})
    end
  
    def mark_as_ham(options={})
    end
    
    # Automatically determines whether to mark as spam or ham depending on a 
    # boolean switch, +is_spam+. The post will be marked as spam when 
    # +is_spam+ is +true+. The post will be marked as ham if +is_spam+ is 
    # +false+.
    #
    # ==== Arguments
    # +is_spam+ <Boolean>:: 
    #   determines whether to mark a post as spam or ham -- spam when true, 
    #   ham when false
    # 
    # +options+ <Hash>:: 
    #   any options either +mark_as_spam+ or +mark_as_ham+ accepts
    def mark_as_spam_or_ham(is_spam, options={})
      is_spam ? mark_as_spam(options) : mark_as_ham(options)
    end
    
    def stats
    end

    def self.logger
      Viking.logger
    end
    
    def logger
      Viking.logger
    end
    
    # Checks to ensure that the minimum number of +options+ have been provided 
    # to make a call to the spam protection service.
    # 
    # Required options include:
    # * +api_key+
    # * +blog+
    # 
    # See the module for your desired spam protection service for details on 
    # the format of these options.
    def invalid_options?
      options[:api_key].nil? || options[:blog].nil?
    end
    
  protected
  
    def log_request(url, data, response)
      return unless logger
      logger.info("[#{self.class.name}] POST '%s' with %s" % [url, data])
      logger.debug(">> #{response.body.inspect}")
    end
    
  end
  
end
