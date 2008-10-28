require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

# Story: Commenting on a blog article (TODO page caching?, access control)
#   As a user with a given role that allows me to comment in a blog
#   I want to comment on an article
#   So I can share my opinions
class BlogArticleTest < ActionController::IntegrationTest
  include CacheableFlash::TestHelpers

  # TODO: make caching work correctly

  def setup
    #enable_page_caching!
    #flush_page_cache!
  end

  # NOTE: merged two stories (An anonymous user comments on an article + An anonymous user updates a comment that he has submitted)
  def test_an_anonymous_user_comments_on_an_article_and_then_edits_the_comment
    site = Factory :site_with_blog
    article = Factory :published_blog_article
    site.sections.first.articles = [article]
    # allow anonymous comments
    site.sections.first.update_attributes! 'permissions' => {'comment' => {'show' => 'anonymous', 'create' => 'anonymous'}}

    # go to article show page
    get "/2008/10/16/adva-cms-kicks-ass"

    # check that the page shows a comment form ...
    assert_select "div#comment_form" do
      # ... and the form contains anonymous fiels.
      assert_select "div#anonymous_author" do
        assert_select "input#anonymous_name"
        assert_select "input#anonymous_email"
      end
    end

    # fill in data and submit the form
    fills_in "anonymous_name", :with => "John Doe"
    fills_in "anonymous_email", :with => "john@example.com"
    fills_in "comment_body", :with => "Really good article!"
    clicks_button "Submit comment"

    # check that the request was successful
    assert_response :success

    # check that the article has now one unapproved comment
    assert_equal 1, article.unapproved_comments.count
    comment = article.unapproved_comments.first

    # hackety hack
    # instance_variable_set(:@html_document, HTML::Document.new(response.body, false, (@response.content_type =~ /xml$/)))
    get "/comments/#{comment.id}"

    # check that the user is redirected to the comment show page
    # assert_redirected_to comment_url(comment) # doesn't seem to work?
    assert_template "comments/show"

    # check that the comment is present
    assert_select "div.comment", { :text => /Really good article!/ }

    # check that the page shows that the comment is currently under review
    assert_select "p.info", "This comment is currently under review."

    # check that the page has an edit form
    assert_select "form[action=?]", comment_path(comment) do
      assert_select "input#anonymous_name"
      assert_select "input#anonymous_email"
    end

    # update the body and submit the form
    fills_in "comment_body", :with => "Really good article! Hope to see more like that in the future!"
    clicks_button "Save comment"

    # check that the request was successful
    assert_response :success

    # hackety hack
    # instance_variable_set(:@html_document, HTML::Document.new(response.body, false, (@response.content_type =~ /xml$/)))
    get "/comments/#{comment.id}"

    # check that the user is back at the comment show page
    assert_template "comments/show"

    # check that the comment has been updated
    assert_select "div.comment", { :text => /Really good article! Hope to see more like that in the future!/ }
  end
end