require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module IntegrationTests
  class SpamBotsTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with blog'
      @blog = @site.sections.first
      @article = @blog.articles.first
    end
    
    test "comment should be rejected when sent as an anonymous and default spam filter is set to 'authenticated'" do
      set_ham_options_to_authenticated
      visit_the_article
      fill_and_post_hidden_comment_form
      comment_is_rejected
    end
    
    test "comment should be rejected when sent as an anonymous and spam filter is disabled" do
      disable_spam_filtering
      visit_the_article
      fill_and_post_hidden_comment_form
      comment_is_rejected
    end
    
    def visit_the_article
      get "/#{@blog.permalink}/2008/1/1/#{@article.permalink}"
      assert_template 'articles/show'
    end
    
    def fill_and_post_hidden_comment_form
      @comment_count = Comment.count
      
      fill_in 'user_name',    :with => 'Spambot'
      fill_in 'user_email',   :with => 'spammy@bothell.org'
      fill_in 'comment_body', :with => 'BUY OUR VIAGRA NOW HTTP://ADVA-CMS.ORG'
      click_button 'Submit comment'
    end
    
    def comment_is_rejected
      assert Comment.count == @comment_count
    end
  end
end