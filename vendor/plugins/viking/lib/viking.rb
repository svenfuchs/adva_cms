module Viking
  class Error < StandardError; end
  
  class << self
    attr_accessor :logger
    attr_accessor :default_engine
    attr_accessor :connect_options
    attr_writer   :default_instance

    def default_instance
      @default_instance ||= connect(default_engine, connect_options)
    end
  
    def connect(engine, options)
      require "viking/#{engine}"
      Viking.const_get(engine.to_s.capitalize).new(options)
    end
    
    def verified?()                 default_instance.verified?;              end
    def check_article(options = {}) default_instance.check_article(options); end
    def check_comment(options = {}) default_instance.check_comment(options); end
    def mark_as_spam(options = {})  default_instance.mark_as_spam(options);  end
    def mark_as_ham(options = {})   default_instance.mark_as_ham(options);   end
    def stats()                     default_instance.stats;                  end
  end
end

require 'viking/base'