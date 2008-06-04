require 'net/http'
require 'uri'
require 'set'

# Akismet
#
# Author:: David Czarnecki
# Copyright:: Copyright (c) 2005 - David Czarnecki
# License:: BSD
#
# rewritten to be more rails-like
module Viking
  class Akismet < Base
    class << self
      attr_accessor :valid_responses, :normal_responses, :standard_headers, :host, :port
    end

    self.host             = 'rest.akismet.com'
    self.port             = 80
    self.valid_responses  = Set.new(['false', ''])
    self.normal_responses = valid_responses.dup << 'true'
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
      @verified_key = false
    end

    # Returns <tt>true</tt> if the API key has been verified, <tt>false</tt> otherwise
    def verified?
      (@verified_key ||= verify_api_key) != :false
    end

    # This is basically the core of everything. This call takes a number of arguments and characteristics about the submitted content and then returns a thumbs up or thumbs down. Almost everything is optional, but performance can drop dramatically if you exclude certain elements.
    #
    # user_ip (required)
    #    IP address of the comment submitter.
    # user_agent (required)
    #    User agent information.
    # referrer (note spelling)
    #    The content of the HTTP_REFERER header should be sent here.
    # permalink
    #    The permanent location of the entry the comment was submitted to.
    # comment_type
    #    May be blank, comment, trackback, pingback, or a made up value like "registration".
    # comment_author
    #    Submitted name with the comment
    # comment_author_email
    #    Submitted email address
    # comment_author_url
    #    Commenter URL.
    # comment_content
    #    The content that was submitted.
    # Other server enviroment variables
    #    In PHP there is an array of enviroment variables called $_SERVER which contains information about the web server itself as well as a key/value for every HTTP header sent with the request. This data is highly useful to Akismet as how the submited content interacts with the server can be very telling, so please include as much information as possible.
    def check_comment(options = {})
      return false if @options[:api_key].nil? || @options[:blog].nil?
      message = call_akismet('comment-check', options)
      {:spam => !self.class.valid_responses.include?(message), :message => message}
    end
  
    # This call is for submitting comments that weren't marked as spam but should have been. It takes identical arguments as comment check.
    # The call parameters are the same as for the #commentCheck method.
    def mark_as_spam(options = {})
      return false if @options[:api_key].nil? || @options[:blog].nil?
      {:message => call_akismet('submit-spam', options)}
    end
  
    # This call is intended for the marking of false positives, things that were incorrectly marked as spam. It takes identical arguments as comment check and submit spam.
    # The call parameters are the same as for the #commentCheck method.
    def mark_as_ham(options = {})
      return false if @options[:api_key].nil? || @options[:blog].nil?
      {:message => call_akismet('submit-ham', options)}
    end

    protected
      # Internal call to Akismet. Prepares the data for posting to the Akismet service.
      #
      # akismet_function
      #   The Akismet function that should be called
      # user_ip (required)
      #    IP address of the comment submitter.
      # user_agent (required)
      #    User agent information.
      # referrer (note spelling)
      #    The content of the HTTP_REFERER header should be sent here.
      # permalink
      #    The permanent location of the entry the comment was submitted to.
      # comment_type
      #    May be blank, comment, trackback, pingback, or a made up value like "registration".
      # comment_author
      #    Submitted name with the comment
      # comment_author_email
      #    Submitted email address
      # comment_author_url
      #    Commenter URL.
      # comment_content
      #    The content that was submitted.
      # Other server enviroment variables
      #    In PHP there is an array of enviroment variables called $_SERVER which contains information about the web server itself as well as a key/value for every HTTP header sent with the request. This data is highly useful to Akismet as how the submited content interacts with the server can be very telling, so please include as much information as possible.  
      def call_akismet(akismet_function, options = {})
        http = Net::HTTP.new("#{@options[:api_key]}.#{self.class.host}", self.class.port, @options[:proxy_host], @options[:proxy_port])
        data = options.update(:blog => @options[:blog]).to_query
        http_post(http, akismet_function, data)
      end

      # Call to check and verify your API key. You may then call the #hasVerifiedKey method to see if your key has been validated.
      def verify_api_key
        return :false if @options[:api_key].nil? || @options[:blog].nil?
        http = Net::HTTP.new(self.class.host, self.class.port, @options[:proxy_host], @options[:proxy_port])
        value = http_post(http, 'verify-key', {:key => @options[:api_key], :blog => @options[:blog]}.to_query)
        @verified_key = (value == "valid") ? true : :false
      end
      
      def http_post(http, action, data)
        url = "/1.1/#{action}"
        resp = http.post(url, data, self.class.standard_headers)
        log_request url, data, resp
        resp.body
      end
  end
end