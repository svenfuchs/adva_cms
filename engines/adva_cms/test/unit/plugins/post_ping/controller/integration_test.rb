# FIXME was commented out ... what's wrong here?

=begin FIX

require File.expand_path(File.dirname(__FILE__) + '/../../../../test_helper')

describe "ArticlePingObserver controller integration", :type => :controller do
  controller_name "admin/articles"
  include SpecControllerHelper

  before :each do
    ArticlePingObserver::SERVICES.clear
    @observer = ArticlePingObserver.instance

    @site = Site.create :title => 'site title', :name => 'site name', :host => 'localhost'
    @blog = Blog.create :title => 'blog title', :site => @site
    @user = stub_user
    @article = Article.create :title => 'article title', :body => 'article body', :section => @blog, :author => @user
    User.stub!(:find).and_return(@user)

    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true

    @controller.stub!(:current_user).and_return stub_user
    @member_url = "/admin/sites/#{@site.id}/sections/#{@blog.id}/articles/#{@article.id}"
    @published_at_params = {:"published_at(1i)" => "2008", :"published_at(2i)"=>"9", :"published_at(3i)"=>"29"}
  end
  
  def publish_article!
    Article.with_observers('article_ping_observer') do 
      request_to :put, @member_url, :article => @published_at_params.merge(:author => @user.id)
    end
  end

  it "does not ping a blog service if the article is not published" do
    @observer.should_not_receive(:ping_service)
    publish_article!
  end
  
  # seems to conflict with the singleton pattern of the observer?
  # it "calls the after_save callback if the article is published" do
  #   Article.should_receive(:find).and_return(@article)
  #   @observer.should_receive(:after_save).with(@article)
  #   publish_article!
  # end
  
  it "pings ping-o-matic if the article is published and pom_get is set as a service" do
    ArticlePingObserver::SERVICES << { :url => "http://ping-o-matic.com", :type => :pom_get }
    @pom_get_url = "http://ping-o-matic.com?title=blog title&blogurl=http://test.host/blogs/#{@blog.id}&rssurl=http://test.host/blogs/#{@blog.id}.atom"
    Net::HTTP.should_receive(:get).any_number_of_times.with URI.parse(URI.escape(@pom_get_url))
    publish_article!
  end

  it "does a rest_ping ping if article is published and rest_ping is set as service" do
    url = "http://rest-ping.com"
    ArticlePingObserver::SERVICES << { :url => url, :type => :rest }
    Net::HTTP.should_receive(:post_form).any_number_of_times.with do |uri, params|
      uri.url.should == url
      params.should == {"name"=>"blog title", "url"=>"http://test.host/blogs/1"}
      Net::HTTPSuccess
    end
    publish_article!
  end

  it "does a xmlrpc_ping ping if article is published and xmlrpc_ping is set as service" do
    require 'xmlrpc/client'
    
    url = "http://xmlrpc-ping.com"
    ArticlePingObserver::SERVICES << { :url => url, :type => :xmlrpc }
    client = XMLRPC::Client.new2(url)
    XMLRPC::Client.should_receive(:new2).and_return(client) 

    params = ["blog title", "http://test.host/blogs/#{@blog.id}", "http://test.host/blogs/#{@blog.id}.atom", ""]
    client.should_receive(:call2).with('weblogUpdates.extendedPing', *params)
    publish_article!
  end
end
=end
