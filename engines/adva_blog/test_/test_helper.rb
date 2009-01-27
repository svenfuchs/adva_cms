require File.expand_path(File.dirname(__FILE__) + '/../../adva_cms/test_/test_helper')

Dir[File.dirname(__FILE__) + "/test_init/**/*.rb"].each { |path| require path }

module ActionController
  class IntegrationTest
    def displays_article(article)
      has_tag '.entry .content', :text => /#{article.title}/
    end
  
    def does_not_display_article(article)
      has_tag '.entry .content', :text => /#{article.title}/, :count => 0
    end
    
    def displays_comments(comments)
      comments.each do |comment|
        has_tag ".comment", :text => /#{comment.body}/
      end
    end
  
    def renders_template(template)
      assert_response :success
      assert_template template
    end
  
    def use_site!(name)
      returning Site.find_by_name name do |site|
        @integration_session = open_session
        @integration_session.host! site.host
      end
    end
    
    def login_as_admin
      post "/session", :user => {:email => 'an-admin@example.com', :password => 'a password'}
      assert controller.authenticated?
      assert controller.current_user.has_role?(:admin, :context => controller.site)
    end
    
  end
end