=begin FIX
require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/../../spec_helpers/spec_activity_helper'

require 'xmlrpc/client'

# in a controller spec for the Admin::ArticlesController
# when you make sure that there's an article in the contents table
# and you send a POST request to the controller so it sets the article state to published
# then it should send the pings to the services as configured in ArticlePingObserver::SERVICES

describe ArticlePingObserver do
  include Stubby

  before :each do
    ArticlePingObserver::SERVICES.clear
    @controller = mock("controller")
    @controller.stub!(:blog_url).and_return('http://www.host.com/blog')
    @controller.stub!(:formatted_blog_url).and_return('http://www.host.com/blog.atom')
    
    @observer = ArticlePingObserver.instance
    @observer.stub!(:controller).and_return(@controller)
    
    @article = stub_article
    @site = stub_site
    @site.stub!(:host).and_return('http://www.host.com')
    @site.stub!(:title).and_return('title')
    @article.stub!(:published?).and_return true
    @article.stub!(:site).and_return @site
    
    @pom_get_url = "http://my.pom.get.ping.site?title=section title&blogurl=http://www.host.com/blog&rssurl=http://www.host.com/blog.atom"
  end

  it "does not ping when the article is not published" do
    @article.should_receive(:published?).and_return false
    @observer.should_not_receive(:rest_ping)
    @observer.should_not_receive(:pom_get_ping)
    @observer.should_not_receive(:xmlrpc_ping)
    @observer.after_save(@article)
  end

  it "does a :rest_ping when the service type is :rest" do
    ArticlePingObserver::SERVICES << { :url => "http://my.rest.ping.site", :type => :rest }
    @observer.should_receive(:rest_ping)
    @observer.should_not_receive(:pom_get_ping)
    @observer.should_not_receive(:xmlrpc_ping)
    @observer.after_save(@article)
  end
  
  it "does a :pom_get_ping when the service type is :pom_get" do
    ArticlePingObserver::SERVICES << { :url => "http://my.pom.get.ping.site", :type => :pom_get }
    @observer.should_not_receive(:rest_ping)
    @observer.should_receive(:pom_get_ping)
    @observer.should_not_receive(:xmlrpc_ping)
    @observer.after_save(@article)
  end
  
  it "defaults to a :xmlrpc_ping when the service type is anything else than :rest or :pom_get" do
    ArticlePingObserver::SERVICES << { :url => "http://my.xmlrpc.ping.site", :type => :anything_else }
    @observer.should_not_receive(:rest_ping)
    @observer.should_not_receive(:pom_get_ping)
    @observer.should_receive(:xmlrpc_ping)
    @observer.after_save(@article)
  end
  
  it "does a :pom_get ping" do
    url = URI.escape @pom_get_url
    uri = URI.parse url
    Net::HTTP.should_receive(:get).with uri
    @observer.send :pom_get_ping, "http://my.pom.get.ping.site", @article
  end
  
  it "does a :rest_ping ping" do
    success = mock(Net::HTTPSuccess)
    success.stub!(:kind_of?).and_return true
    success.stub!(:body)
    post_info = { "name" => 'section title', "url" => 'http://www.host.com/blog' }
    uri = URI.parse "http://my.rest.ping.site"
    Net::HTTP.should_receive(:post_form).with(uri, post_info).and_return(success)
    @observer.send :rest_ping, "http://my.rest.ping.site", @article
  end
  
  it "does a :xmlrpc_ping ping" do
    client = mock(XMLRPC::Client)
    XMLRPC::Client.stub!(:new2).and_return client
  
    blog_url = "http://www.host.com/blog"
    feed_url = "http://www.host.com/blog.atom"
    @article.stub!(:tags).and_return %w(foo bar)
    client.should_receive(:call2).with('weblogUpdates.extendedPing', "section title", blog_url, feed_url, "foo|bar")
  
    @observer.send :xmlrpc_ping, "http://my.xmlrpc.ping.site", @article
  end
  
  it "#pom_get_url returns a pingomatic url" do
    url = @observer.send :pom_get_url, "http://my.pom.get.ping.site", @article
    url.should == @pom_get_url
  end
end
=end
