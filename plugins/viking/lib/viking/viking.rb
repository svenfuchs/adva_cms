$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# = Description
# Provides a simple interface to polymorphically access to the spam protection 
# service of your choice.
# 
# = Usage
# I find it useful to first initialize Viking in a separate file during 
# framework initialization. Rails initializers, for instance, work great for 
# this. An example of such an initializer would be as follows:
# 
#   Viking.default_engine = 'defensio'
#   Viking.connect_options = { :api_key => '1234abc' }
# 
# From this point out, Viking should have everything it needs to access the 
# service of your choice. Merely call methods on your service of choice as 
# documented. For instance:
# 
#   Viking.mark_as_spam(:signaturs => "1234abc")
module Viking
  class Error < StandardError; end

  class << self
    attr_accessor :timeout_threshold
    attr_accessor :logger
    attr_accessor :default_engine
    attr_writer   :connect_options
    attr_writer   :default_instance

    def connect_options
      @connect_options ||= {}
    end

    def default_instance
      @default_instance ||= connect(default_engine, connect_options)
    end

    def enabled?
      !default_instance.nil?
    end

    def connect(engine, options)
      unless engine.nil? || engine.empty?
        require(engine)
        Viking.const_get(engine.to_s.capitalize).new(options)
      end
    end

    def verified?()               default_instance.verified?;              end
    def check_article(options={}) default_instance.check_article(options); end
    def check_comment(options={}) default_instance.check_comment(options); end
    def mark_as_spam(options={})  default_instance.mark_as_spam(options);  end
    def mark_as_ham(options={})   default_instance.mark_as_ham(options);   end
    def stats()                   default_instance.stats;                  end

    def mark_as_spam_or_ham(is_spam, options={})
      default_instance.mark_as_spam_or_ham(is_spam, options)
    end
  end

  self.timeout_threshold = 5
end

require 'base'