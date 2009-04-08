require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

if Rails.plugin?(:adva_post_ping)
  module IntegrationTests
    class AdminBlogPingTest < ActionController::IntegrationTest
      def setup
        super
        @section = Blog.first
        @site = @section.site
        use_site! @site
        stub(Time).now.returns Time.utc(2008, 1, 2)
      
        Article.old_add_observer(@observer = ArticlePingObserver.instance)

        @ping_service = { :url => "http://rpc.pingomatic.com/", :type => :xmlrpc }
        ArticlePingObserver::SERVICES.replace [@ping_service]
      end
    
      def teardown
        super
        Article.delete_observer(@observer)
      end
  
      test "The system pings FOO when a blog article is published" do
        login_as_admin
      
        visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles"
        click_link "New"

        expect_no_pings do
          create_a_new_article
        end
      
        expect_ping_to(@ping_service) do
          publish_article
        end
      end

      def create_a_new_article
        fill_in 'article[title]', :with => 'the article title'
        fill_in 'article[body]',  :with => 'the article body'
        click_button 'Save'
        request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
      end

      def publish_article
        uncheck 'article[draft]'
        select_date "2008-1-1", :from => 'Publish on this date'
        click_button 'Save'
        request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
      end
    
      def expect_no_pings
        RR.dont_allow(ArticlePingObserver.instance).ping_service(anything, anything)
        yield
        RR.verify
        RR.reset
      end
    
      def expect_ping_to(service)
        RR.mock(ArticlePingObserver.instance).ping_service(service, anything)
        yield
        RR.verify
        RR.reset
      end
    end
  end
end