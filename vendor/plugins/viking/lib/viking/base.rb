module Viking
  class Base
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def verified?
    end

    def check_article(options = {})
    end

    def check_comment(options = {})
    end
  
    def mark_as_spam(options = {})
    end
  
    def mark_as_ham(options = {})
    end
    
    def stats
    end

    def self.logger
      Viking.logger
    end
    
    def logger
      Viking.logger
    end
    
    protected
      def log_request(url, data, response)
        return unless logger
        logger.info("[#{self.class.name}] POST '%s' with %s" % [url, data])
        logger.debug(">> #{response.body.inspect}")
      end
  end
end