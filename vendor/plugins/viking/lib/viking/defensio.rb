require 'net/http'
require 'uri'
require 'yaml'

module Viking
  class Defensio < Base
    class << self
      attr_accessor :host, :port, :api_version, :standard_headers, :service_type
    end
    
    attr_accessor :proxy_port, :proxy_host
    attr_reader :last_response

    self.service_type = :blog
    self.host = 'api.defensio.com'
    self.api_version = '1.1'
    self.standard_headers = {
      'User-Agent'   => 'Viking (Rails Plugin) v0.5',
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
  
    # Create a new instance of the Akismet class
    #
    # :api_key 
    #   Your Akismet API key
    # :blog 
    #   The blog associated with your api key
    # :proxy_port
    # :proxy_host
    def initialize(options)
      super
      @verify_options = false
    end

    # Returns <tt>true</tt> if the API key has been verified, <tt>false</tt> otherwise
    def verified?
      (@verify_options ||= call_defensio('validate-key'))[:status] == 'success'
    end

    def check_article(options = {})
      return false if @options[:api_key].nil? || @options[:blog].nil?
      call_defensio 'announce-article', options
    end

    def check_comment(options = {})
      return false if @options[:api_key].nil? || @options[:blog].nil?
      if options[:article_date].respond_to?(:strftime)
        options[:article_date] = options[:article_date].strftime("%Y/%m/%d")
      end
      call_defensio 'audit-comment', options
    end
  
    def mark_as_spam(options = {})
      return false if @options[:api_key].nil? || @options[:blog].nil?
      call_defensio 'report-false-negatives', options
    end
  
    def mark_as_ham(options = {})
      return false if @options[:api_key].nil? || @options[:blog].nil?
      call_defensio 'report-false-positives', options
    end
  
    def stats
      return false if @options[:api_key].nil? || @options[:blog].nil?
      call_defensio 'get-stats'
    end

    protected
      def api_url(action)
        URI.escape("/#{self.class.service_type}/#{self.class.api_version}/#{action}/#{@options[:api_key]}.yaml")
      end

      def call_defensio(action, params = {})
        url  = api_url(action)
        data = params.inject({'owner-url' => @options[:blog] || @options[:owner_url]}) do |memo, (key, value)|
          memo[key.to_s.dasherize] = value
          memo
        end.to_query
        http = Net::HTTP.new(self.class.host, self.class.port, @options[:proxy_host], @options[:proxy_port])
        resp = http.post(url, data, self.class.standard_headers)
        log_request url, data, resp
        data = YAML.load(resp.body)
        (data.respond_to?(:key?) && data.key?('defensio-result')) ? data['defensio-result'].symbolize_keys : {:data => resp.body, :status => 'fail'}
      end
  end
end