require 'net/http'
require 'uri'
require 'yaml'

# = Defensio
# Adapted from code originally by Technoweenie. Updated to the 1.2 API, and 
# refactored.
# 
# = License
# Technoweenie fails to mention the license of his original code, so I assume 
# that it is either under MIT or public domain. As such, I release this code 
# under the MIT license.
# 
# Copyright (c) 2008, James Herdman
# 
# = Important Note
# * most documentation below is adapted from the Defensio API (v 1.2) manual
# * unless otherwise stated, all arguments are expected to be Strings
module Viking
  class Defensio < Base
    class << self
      attr_accessor :host, :port, :api_version, :standard_headers, :service_type
    end

    attr_accessor :verify_options
    attr_accessor :proxy_port, :proxy_host
    attr_reader   :last_response

    self.service_type     = :blog
    self.host             = 'api.defensio.com'
    self.api_version      = '1.2'
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
    # +api_key+::    your Defensio API key
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
      self.verify_options = false
    end

    # This action verifies that the key is valid for the owner calling the 
    # service. A user must have a valid API key in order to use Defensio.
    # 
    # ==== Returns
    # true, false
    def verified?
      return false if invalid_options?
      (@verify_options ||= call_defensio('validate-key'))[:status] == 'success'
    end

    # This action should be invoked upon the publication of an article to 
    # announce its existence. The actual content of the article is sent to 
    # Defensio for analysis.
    # 
    # ==== Arguments
    # Provided in a Hash with the following keys:
    # 
    # +owner_url+ (*required*):: 
    #   the URL of the owner using Defensio. Note that this value should be 
    #   provided in your default options for Viking and will be automatically 
    #   inserted into your call.
    # +article_author+ (*required*):: 
    #   the name of the author of the article
    # +article_author_email+ (*required*)::
    #   the email address of the article's author
    # +article_title+ (*required*)::
    #   the title of the article
    # +article_content+ (*required*)::
    #   the contents of the article
    # +permalink+ (*required*)::
    #   the permalink of the article
    # 
    # ==== Returns
    # Hash:: 
    #   contains server response. Should things go awry, the full response 
    #   will be provided.
    # 
    # ===== Response structure
    # The following are the fields returned from the server and their possible 
    # values:
    # 
    # +status+::
    #   indicates whether or not the key is valid for this blog. Either 
    #   'success' or 'fail'.
    # +message+::
    #   the message provided by the action, if applicable
    # +api_version+::
    #   the API version used to process the request
    def check_article(options={})
      return false if invalid_options?
      call_defensio 'announce-article', options
    end

    # This central action determines not only whether Defensio thinks a 
    # comment is spam or not, but also a measure of its "spaminess", i.e. its 
    # relative likelihood of being spam.
    # 
    # It should be noted that one of Defensio's key features is its ability to 
    # rank spam according to how "spammy" it appears to be. In order to make 
    # the most of the Defensio system in their applications, developers should 
    # take advantage of the spaminess value returned by this function, to 
    # build interfaces that make it easy for the user to quickly sort through 
    # and manage their spamboxes.
    # 
    # ==== Arguments
    # Provide arguments in a Hash. The following keys are available:
    # 
    # +owner_url+ (*required*):: 
    #   the URL of the owner using Defensio. Note that this value should be 
    #   provided in your default options for Viking and will be automatically 
    #   inserted into your call.
    # +user_ip+ (*required*)::
    #   the IP address of whomever is posting the comment
    # +article_date+  <~strftime> (*required*)::
    #   the date the original blog article was posted
    # +comment_author+ (*required*):: 
    #   the name of the author of the comment
    # +comment_type+ (*required*)::
    #   the type of comment being posted to the article. This is expected to 
    #   be any of the following: 'comment', 'trackback', 'pingback', 'other'
    # +comment_content+::
    #   the content of the comment in question
    # +comment_author_email+::
    #   the email address of the comment's author
    # +permalink+::
    #   the permalink of the blog post to which the comment is being posted
    # +referrer+::
    #   the URL of the site that brought the commenter to this page
    # +user_logged_in+::
    #   whether or not the user leaving the comment is logged into the client 
    #   platform. Expected to be either +true+ or +false+.
    # +trusted_user+::
    #   whether or not the user is an administrator or modertor or editor of 
    #   the blog. This should only ever be true if the blogging platform can 
    #   guarentee that the user has been authenticated and authorized for this 
    #   role. This is expected to be either +true+ or +false+.
    # +openid+::
    #   the OpenID URL of the currently logged in user. Must be used in 
    #   conjunction with +user_logged_in+ as +true+. OpenID authentication 
    #   must be taken care of by your application.
    # +test_force+::
    #   <b>FOR TESTING PURPOSES ONLY</b>: use this parameter to force the 
    #   outcome of +audit_comment+. Optionally affix (with a comma) a desired 
    #   +spaminess+ return value (in the range 0 to 1) (e.g. "spam,x.xxxx" 
    #   "ham,x.xxxx" )
    # 
    # ==== Returns
    # Hash:: 
    #   contains server response. Should things go awry, the full response 
    #   will be provided.
    # 
    # ===== Response structure
    # The following are the fields returned from the server and their possible 
    # values:
    # 
    # +status+::
    #   indicates whether or not the key is valid for this blog. Either 
    #   'success' or 'fail'.
    # +message+::
    #   the message provided by the action, if applicable
    # +api_version+::
    #   the API version used to process the request
    # +signature+::
    #   this uniquely identifies a message in the Defensio system. This should 
    #   be retained by the client for retraining purposes.
    # +spam+::
    #   whether or not Defensio believes the comment to be spam. This will be 
    #   either +true+ or +false+
    # +spaminess+::
    #   a value indicating the relative likelihood that a comment is spam. 
    #   This should be retained to aid in building spam sorting interfaces.
    def check_comment(options={})
      return false if invalid_options?
      options[:article_date] = options[:article_date].strftime("%Y/%m/%d") # e.g. 2007/05/16
      call_defensio 'audit-comment', options
    end
  
    # This action is used to retrain false negatives. That is to say, to 
    # indicate to the filter that comments originally tagged as "ham" (i.e. 
    # legitimate) were in fact spam.
    # 
    # Retraining the filter in this manner contributes to a personalized 
    # learning effect on the filtering algorithm that will improve accuracy 
    # for each user over time.
    # 
    # ==== Arguments
    # Provide arguments in a Hash. The following keys are available:
    # 
    # +owner_url+ (*required*):: 
    #   the URL of the owner using Defensio. Note that this value should be 
    #   provided in your default options for Viking and will be automatically 
    #   inserted into your call.
    # +signatures+ (comma separated Strings)(*required*)::
    #   a comma separated list of signatures (or single entry) to be submitted 
    #   for retraining. The signatures were provided by Defensio when a 
    #   comment was first audited.
    # 
    # ==== Returns
    # Hash:: 
    #   contains server response. Should things go awry, the full response 
    #   will be provided.
    # 
    # ===== Response structure
    # The following are the fields returned from the server and their possible 
    # values:
    # 
    # +status+::
    #   indicates whether or not the key is valid for this blog. Either 
    #   'success' or 'fail'.
    # +message+::
    #   the message provided by the action, if applicable
    # +api_version+::
    #   the API version used to process the request
    def mark_as_spam(options={})
      return false if invalid_options?
      call_defensio 'report-false-negatives', options
    end
  
    # This action is used to retrain false positives. That is to say, to 
    # indicate to the filter that comments originally tagged as spam were in 
    # fact "ham" (i.e. legitimate comments).
    # 
    # Retraining the filter in this manner contributes to a personalized 
    # learning effect on the filtering algorithm that will improve accuracy 
    # for each user over time.
    # 
    # ==== Arguments
    # Provide arguments in a Hash. The following keys are available:
    # 
    # +owner_url+ (*required*):: 
    #   the URL of the owner using Defensio. Note that this value should be 
    #   provided in your default options for Viking and will be automatically 
    #   inserted into your call.
    # +signatures+ (comma separated Strings)(*required*)::
    #   a comma separated list of signatures (or single entry) to be submitted 
    #   for retraining. The signatures were provided by Defensio when a 
    #   comment was first audited.
    # 
    # ==== Returns
    # Hash:: 
    #   contains server response. Should things go awry, the full response 
    #   will be provided.
    # 
    # ===== Response structure
    # The following are the fields returned from the server and their possible 
    # values:
    # 
    # +status+::
    #   indicates whether or not the key is valid for this blog. Either 
    #   'success' or 'fail'.
    # +message+::
    #   the message provided by the action, if applicable
    # +api_version+::
    #   the API version used to process the request
    def mark_as_ham(options={})
      return false if invalid_options?
      call_defensio 'report-false-positives', options
    end

    # This action returns basic statistics regarding the performance of 
    # Defensio since activation
    # 
    # ==== Returns
    # Hash:: 
    #   contains server response. Should things go awry, the full response 
    #   will be provided.
    # 
    # ===== Response structure
    # The following are the fields returned from the server and their possible 
    # values:
    # 
    # +status+::
    #   indicates whether or not the key is valid for this blog. Either 
    #   'success' or 'fail'.
    # +message+::
    #   the message provided by the action, if applicable
    # +api_version+::
    #   the API version used to process the request
    # +accuracy+::
    #   a value between 0 and 1 representing the percentage of comments 
    #   correctly identified as spam or ham by Defensio on this blog
    # +spam+::
    #   the number of spam comments caught by the filter
    # +ham+::
    #   the number of legitimate comments caught by the filter
    # +false_positives+::
    #   the number of times legitimate messages have been retrained (i.e. 
    #   "de-spammed") by the user
    # +false_negatives+::
    #   the number of times a comments had to be marked as spam by the user
    # +learning+::
    #   whether or not Defensio is still in its initial learning phase (either 
    #   +true+ or +false+)
    # +learning_status+::
    #   more reasons on why Defensio is still learning
    def stats
      return false if invalid_options?
      call_defensio 'get-stats'
    end
    
    # Formats a URL for use with the Defensio service.
    # 
    # ==== Arguments
    # +action+ <String>:: the action you wish to call
    # 
    # ==== Returns
    # String
    # 
    # ==== Example
    #   > defensio.url('get-stats')
    #   => '/blog/1.2/get-stats/1234abc.yaml'
    def url(action)
      URI.escape(
        [
          '', # ensures opening /
          self.class.service_type, 
          self.class.api_version, 
          action, 
          options[:api_key]
        ].join('/')
      ) << '.yaml'
    end

  protected
    def call_defensio(action, params={})
      params.update('owner-url' => options[:blog] || options[:owner_url])
      data = params.dasherize_keys.to_query
      resp = http_instance.post url(action), data, self.class.standard_headers
      log_request(url(action), data, resp)
      process_response_body(resp.body)
    end

    def http_instance
      http = Net::HTTP.new self.class.host, self.class.port, options[:proxy_host], options[:proxy_port]
      http.read_timeout = http.open_timeout = Viking.timeout_threshold
      http
    end

    def process_response_body(response_body)
      data = YAML.load(response_body)
      return data['defensio-result'].symbolize_keys
    rescue
      { :data => data, :status => 'fail' }
    end
  end
end