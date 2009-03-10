require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

if Rails.plugin?(:adva_post_ping)
  require 'xmlrpc/client'

  # in a controller test for the Admin::ArticlesController
  # when you make sure that there's an article in the contents table
  # and you send a POST request to the controller so it sets the article state to published
  # then it should send the pings to the services as configured in ArticlePingObserver::SERVICES

  class ArticlePingObserverTest < ActiveSupport::TestCase
    def setup
      super
      ArticlePingObserver::SERVICES.clear
      @controller = ActionController::Base.new
      @observer = ArticlePingObserver.instance
      @blog = Blog.first
      @article = @blog.articles.first
      @site = @article.site
    
      @blog_url = "http://#{@site.host}/blog"
      @blog_feed_url = @blog_url + '.atom'
      @pom_get_url = "http://my.pom.get.ping.site?title=#{@blog.title}&blogurl=#{@blog_url}&rssurl=#{@blog_feed_url}"

      stub(@observer).controller.returns @controller
      stub(@controller).blog_url.returns @blog_url
      stub(@controller).blog_feed_url.with(@blog, :format => :atom).returns @blog_feed_url
    end

    test "does not ping when the article is not published" do
      @article.published_at = nil
      dont_allow(@observer).rest_ping
      dont_allow(@observer).pom_get_ping
      dont_allow(@observer).xmlrpc_ping
      @observer.after_save(@article)
    end

    test "does a :rest_ping when the service type is :rest" do
      ArticlePingObserver::SERVICES << { :url => "http://my.rest.ping.site", :type => :rest }
      mock(@observer).rest_ping("http://my.rest.ping.site", @article)
      dont_allow(@observer).pom_get_ping
      dont_allow(@observer).xmlrpc_ping
      @observer.after_save(@article)
    end
  
    test "does a :pom_get_ping when the service type is :pom_get" do
      ArticlePingObserver::SERVICES << { :url => "http://my.pom.get.ping.site", :type => :pom_get }
      mock(@observer).pom_get_ping("http://my.pom.get.ping.site", @article, nil)
      dont_allow(@observer).rest_ping
      dont_allow(@observer).xmlrpc_ping
      @observer.after_save(@article)
    end
  
    test "defaults to a :xmlrpc_ping when the service type is anything else than :rest or :pom_get" do
      ArticlePingObserver::SERVICES << { :url => "http://my.xmlrpc.ping.site", :type => :anything_else }
      mock(@observer).xmlrpc_ping("http://my.xmlrpc.ping.site", @article)
      dont_allow(@observer).rest_ping
      dont_allow(@observer).pom_get_ping
      @observer.after_save(@article)
    end
  
    test "does a :pom_get ping" do
      url = URI.escape @pom_get_url
      uri = URI.parse url
      mock(Net::HTTP).get(uri)
      @observer.send :pom_get_ping, "http://my.pom.get.ping.site", @article
    end
  
    test "does a :rest_ping ping" do
      uri = URI.parse "http://my.rest.ping.site"
      post_info = { "name" => @blog.title, "url" => @blog_url }

      success = Net::HTTPSuccess.new(:httpv, :code, :msg)
      stub(success).kind_of?(anything).returns true
      stub(success).body.returns ''
    
      mock(Net::HTTP).post_form(uri, post_info).returns(success)
      @observer.send :rest_ping, "http://my.rest.ping.site", @article
    end
  
    test "does a :xmlrpc_ping ping" do
      client = XMLRPC::Client.new
      stub(XMLRPC::Client).new2.returns client

      mock(client).call2('weblogUpdates.extendedPing', @blog.title, @blog_url, @blog_feed_url, "foo|bar")
      @observer.send :xmlrpc_ping, "http://my.xmlrpc.ping.site", @article
    end
  
    test "#pom_get_url returns a pingomatic url" do
      url = @observer.send :pom_get_url, "http://my.pom.get.ping.site", @article
      url.should == @pom_get_url
    end
  end
end