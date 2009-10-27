require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

# FIXME seems there's a permission problem so comments can't be posted?
module IntegrationTests
  class SpamControlTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with blog'
      @blog = @site.sections.first
      @article = @blog.articles.first
    end

    test "A site w/ default filter and the ham option not set does not approve an anonymous comment" do
      allow_anonymous_commenting
      set_ham_options_to_none
      visit_the_article
      fill_and_post_the_comment_form
      assert ! Comment.last.approved?
    end

    test "A site w/ default filter and the ham option set to all approves an anonymous comment" do
      allow_anonymous_commenting
      set_ham_options_to_all
      visit_the_article
      fill_and_post_the_comment_form
      assert Comment.last.approved?
    end

    test "A site w/ default filter and the ham option set to authorized does not approve an anonymous comment" do
      allow_anonymous_commenting
      set_ham_options_to_authenticated
      visit_the_article
      fill_and_post_the_comment_form
      assert ! Comment.last.approved?
    end
    
    test "A site w/ default filter and the ham option set to authorized approves an authenticated comment" do
      set_ham_options_to_authenticated
      login_as_user
      visit_the_article
      fill_and_post_the_comment_form_as_authenticated
      assert Comment.last.approved
    end
    
    test "A site w/ Akismet filter returnin 'spam' does not approve a comment (when default filter is set to 'none')" do
      allow_anonymous_commenting
      set_akismet_as_spam_engine
      stub_akismet_service({:spam => true})
    
      visit_the_article
      fill_and_post_the_comment_form
      assert ! Comment.last.approved?
    end
    
    test "A site w/ Akismet filter returning 'ham' approves a comment (when default filter is set to 'none')" do
      allow_anonymous_commenting
      set_akismet_as_spam_engine
      stub_akismet_service({:spam => false})
    
      visit_the_article
      fill_and_post_the_comment_form
      assert Comment.last.approved?
    end
    
    test "A site w/ Defensio filter returnin 'spam' does not approve a comment (when default filter is set to 'none')" do
      allow_anonymous_commenting
      set_defensio_as_spam_engine
      stub_defensio_service({:spam => true})
    
      visit_the_article
      fill_and_post_the_comment_form
      assert ! Comment.last.approved?
    end
    
    test "A site w/ Defensio filter returning 'ham' approves a comment (when default filter is set to 'none')" do
      allow_anonymous_commenting
      set_defensio_as_spam_engine
      stub_defensio_service({:spam => false})
    
      visit_the_article
      fill_and_post_the_comment_form
      assert Comment.last.approved?
    end

    def visit_the_article
      get "/#{@blog.permalink}/2008/1/1/#{@article.permalink}"
      assert_template 'articles/show'
    end

    def fill_and_post_the_comment_form
      comment_count = Comment.count

      fill_in 'user_name',    :with => 'Anonymous'
      fill_in 'user_email',   :with => 'anonymous@anonymous.org'
      fill_in 'comment_body', :with => 'This is an anonymous message'
      click_button 'Submit Comment'

      assert Comment.count == comment_count + 1
    end

    def fill_and_post_the_comment_form_as_authenticated
      comment_count = Comment.count

      fill_in 'comment_body', :with => 'authenticated comment'
      click_button 'Submit Comment'

      assert Comment.count == comment_count + 1
    end
  end
end
