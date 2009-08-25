require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module IntegrationTests
  class SpamBotsWithAkismet < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with blog'
      @blog = @site.sections.first
      @article = @blog.articles.first
    end
    
    test "messages marked as a spam are unapproved" do
      allow_anonymous_commenting
      set_akismet_as_spam_engine
      stub_akismet_service( spam_message_result(:spam => true) )
      
      visit_the_article
      fill_hidden_form
      assert ! Comment.last.approved?
    end
    
    test "messages marked as a spam are unapproved, and their spaminess value is set to 100" do
      allow_anonymous_commenting
      set_defensio_as_spam_engine
      stub_akismet_service( spam_message_result(:spam => true) )
      
      visit_the_article
      fill_hidden_form
      assert ! Comment.last.approved?
      assert Comment.last.spam_reports.last.spaminess == 100
    end
    
    def visit_the_article
      get "/#{@blog.permalink}/2008/1/1/#{@article.permalink}"
      assert_template 'articles/show'
    end
    
    def spam_message_result(options = {})
      { :spam => options[:spam] || false,
        :message => "#{options[:spam]}" }
    end
    
    def fill_hidden_form
      @comment_count = Comment.count
      
      fill_in 'user_name',    :with => 'ssafdad'
      fill_in 'user_email',   :with => 'trgtwwfwfw@gmail.com'
      fill_in 'comment_body', :with => "spam message"
      click_button 'Submit comment'
      
      assert Comment.count == @comment_count + 1
    end
  end
end