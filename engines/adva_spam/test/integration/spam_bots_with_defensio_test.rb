require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module IntegrationTests
  class SpamBotsWithDefensio < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with blog'
      @blog = @site.sections.first
      @article = @blog.articles.first
    end
    
    test "messages marked as a spam are unaproved" do
      allow_anonymous_commenting
      set_defensio_as_spam_engine
      stub_defensio_service( spam_message_result(:spaminess => 0.51) )
      
      visit_the_article
      fill_hidden_form
      assert ! Comment.last.approved?
    end
    
    test "messages marked as a spam are unaproved, regardless of their actual spaminess value" do
      allow_anonymous_commenting
      set_defensio_as_spam_engine
      stub_defensio_service( spam_message_result(:spaminess => 0.00) )
      
      visit_the_article
      fill_hidden_form
      assert ! Comment.last.approved?
    end
    
    test "messages marked as a spam are unaproved, and their spaminess value is set to 100 regardless of actual spaminess value of defensio" do
      allow_anonymous_commenting
      set_defensio_as_spam_engine
      stub_defensio_service( spam_message_result(:spaminess => 0.00) )
      
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
      { :spaminess => options[:spaminess] || 0,
        :"api-version" => "1.2",
        :status => "success",
        :spam => true,
        :message => "",
        :signature => "f7d72ace4ffrctrdjwkhlt" }
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