require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

module IntegrationTests
  #
  # This test is intended to test how AdvaCms behaves when spambots come and "attack" a site.
  #
  # not included are tests which cover the following scenarios:
  #   rejected requests due to missing AuthenticityToken
  #   not processed requests due to disabled comments
  #
  # The comments which are saved are not approved and have a spaminess of 100.0
  #
  class SpamBotsTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with blog'
      @blog = @site.sections.first
      @article = @blog.articles.first
    end

    test "comment should not be approved when sent as an anonymous and default spam filter is set to 'authenticated'" do
      set_ham_options_to_authenticated
      visit_the_article
      assert_no_new_commment_is_approved do
        fill_and_post_hidden_comment_form
      end
    end

    test "comment should not be approved when sent as an anonymous and spam filter is disabled" do
      disable_spam_filtering
      visit_the_article
      assert_no_new_commment_is_approved do
        fill_and_post_hidden_comment_form
      end
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

    def assert_no_new_commment_is_approved
      assert_no_difference "Comment.count(:conditions => { :approved => true })", "Comment is approved though it shouldn't be" do
        yield
      end
    end
  end
end
