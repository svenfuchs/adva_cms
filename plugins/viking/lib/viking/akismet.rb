require 'net/http'
require 'uri'
require 'set'

# Akismet
#
# Author::    David Czarnecki
# Copyright:: Copyright (c) 2005 - David Czarnecki
# License::   BSD
#
# Rewritten to be more agnostic
module Viking
  class Akismet < Base
    class << self
      attr_accessor :valid_responses, :normal_responses, :standard_headers, 
                    :host, :port
    end

    self.host             = 'rest.akismet.com'
    self.port             = 80
    self.valid_responses  = Set.new(['false', ''])
    self.normal_responses = valid_responses.dup << 'true'
    self.standard_headers = {
      'User-Agent'   => "Viking (Ruby Gem) v#{Viking::VERSION::STRING}",
      'Content-Type' => 'application/x-www-form-urlencoded'
    }
  
    # Create a new instance of the Akismet class
    #
    # ==== Arguments
    # Arguments are provided in the form of a Hash with the following keys 
    # (as Symbols) available: 
    # 
    # +api_key+::    your Akismet API key
    # +blog+::       the blog associated with your api key
    # 
    # The following keys are available and are entirely optional. They are 
    # available incase communication with Akismet's servers requires a 
    # proxy port and/or host:
    # 
    # * +proxy_port+
    # * +proxy_host+
    def initialize(options)
      super
      self.verified_key = false
    end

    # Returns +true+ if the API key has been verified, +false+ otherwise
    def verified?
      (@verified_key ||= verify_api_key) != :false
    end

    # This is basically the core of everything. This call takes a number of 
    # arguments and characteristics about the submitted content and then 
    # returns a thumbs up or thumbs down. Almost everything is optional, but 
    # performance can drop dramatically if you exclude certain elements.
    #
    # ==== Arguments
    # +options+ <Hash>:: describes the comment being verified
    # 
    # The following keys are available for the +options+ hash:
    # 
    # +user_ip+ (*required*):: 
    #   IP address of the comment submitter.
    # +user_agent+ (*required*):: 
    #   user agent information.
    # +referrer+ (<i>note spelling</i>):: 
    #   the content of the HTTP_REFERER header should be sent here.
    # +permalink+:: 
    #   permanent location of the entry the comment was submitted to
    # +comment_type+::
    #   may be blank, comment, trackback, pingback, or a made up value like 
    #   "registration".
    # +comment_author+::
    #   submitted name with the comment
    # +comment_author_email+::
    #   submitted email address
    # +comment_author_url+::
    #   commenter URL
    # +comment_content+::
    #   the content that was submitted
    # Other server enviroment variables::
    #   In PHP there is an array of enviroment variables called <tt>_SERVER</tt> 
    #   which contains information about the web server itself as well as a 
    #   key/value for every HTTP header sent with the request. This data is 
    #   highly useful to Akismet as how the submited content interacts with 
    #   the server can be very telling, so please include as much information 
    #   as possible.
    def check_comment(options={})
      return false if invalid_options?
      message = call_akismet('comment-check', options)
      {:spam => !self.class.valid_responses.include?(message), :message => message}
    end
  
    # This call is for submitting comments that weren't marked as spam but 
    # should have been (i.e. false negatives). It takes identical arguments as 
    # +check_comment+. 
    def mark_as_spam(options={})
      return false if invalid_options?
      {:message => call_akismet('submit-spam', options)}
    end
  
    # This call is intended for the marking of false positives, things that 
    # were incorrectly marked as spam. It takes identical arguments as 
    # +check_comment+ and +mark_as_spam+.
    def mark_as_ham(options={})
      return false if invalid_options?
      {:message => call_akismet('submit-ham', options)}
    end
    
    # Returns the URL for an Akismet request
    # 
    # ==== Arguments
    # +action+ <~to_s>:: a valid Akismet function name
    # 
    # ==== Returns
    # String
    def self.url(action)
      "/1.1/#{action}"
    end

    protected
      # Internal call to Akismet. Prepares the data for posting to the Akismet 
      # service.
      #
      # ==== Arguments
      # +akismet_function+ <String>::
      #   the Akismet function that should be called
      # 
      # The following keys are available to configure a given call to Akismet: 
      # 
      # +user_ip+ (*required*)::
      #   IP address of the comment submitter.
      # +user_agent+ (*required*)::
      #   user agent information.
      # +referrer+ (<i>note spelling</i>)::
      #   the content of the HTTP_REFERER header should be sent here.
      # +permalink+::
      #   the permanent location of the entry the comment was submitted to.
      # +comment_type+::
      #   may be blank, comment, trackback, pingback, or a made up value like 
      #   "registration".
      # +comment_author+::
      #   submitted name with the comment
      # +comment_author_email+::
      #   submitted email address
      # +comment_author_url+::
      #   commenter URL
      # +comment_content+::
      #   the content that was submitted
      # Other server enviroment variables::
      #   In PHP there is an array of enviroment variables called <tt>_SERVER</tt> 
      #   which contains information about the web server itself as well as a 
      #   key/value for every HTTP header sent with the request. This data is 
      #   highly useful to Akismet as how the submited content interacts with 
      #   the server can be very telling, so please include as much information 
      #   as possible.
      def call_akismet(akismet_function, options={})
        http_post http_instance, akismet_function, options.update(:blog => options[:blog])
      end

      # Call to check and verify your API key. You may then call the 
      # <tt>verified?</tt> method to see if your key has been validated
      def verify_api_key
        return :false if invalid_options?
        value = http_post http_instance, 'verify-key', :key  => options[:api_key], :blog => options[:blog]
        self.verified_key = (value == "valid") ? true : :false
      end
      
      def http_post(http, action, options = {})
        data = options.to_query
        resp = http.post(self.url(action), data, self.class.standard_headers)
        log_request(self.url(action), data, resp)
        resp.body
      end
      
      def url(action)
        "/1.1/#{action}"
      end
      
    private
      attr_accessor :verified_key

      def http_instance
        http = Net::HTTP.new([options[:api_key], self.class.host].join("."), options[:proxy_host], options[:proxy_port])
        http.read_timeout = http.open_timeout = Viking.timeout_threshold
        http
      end
  end
end