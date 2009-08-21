require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class BlogCommentTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with blog'
      @site.update_attributes! :permissions => { 'create comment' => 'anonymous' }
      @published_article = Article.find_by_title 'a blog article'
    end
    
    # FIXME test edit/delete comment
    # http://artweb-design.lighthouseapp.com/projects/13992/tickets/215
    test "An anonymous user posts a comment to a blog article" do
      post_a_blog_comment_as_anonymous
      view_submitted_comment
      go_back_to_article
    end
    
    test "A registered user posts a comment to a blog article" do
      login_as_user
      post_a_blog_comment_as_user
      view_submitted_comment
      go_back_to_article
    end
    
    def post_a_blog_comment_as_anonymous
      visit '/2008/1/1/a-blog-article'
      fill_in "user_name", :with => "John Doe"
      fill_in "user_email", :with => "john@example.com"
      fill_in "comment_body", :with => "What a nice article!"
      click_button "Submit comment"
    end
    
    def post_a_blog_comment_as_user
      visit '/2008/1/1/a-blog-article'
      fill_in "comment_body", :with => "What a nice article!"
      click_button "Submit comment"
    end
    
    def view_submitted_comment
      request.url.should =~ %r(#{@site.host}/comments/\d+)
      has_tag ".comment", /What a nice article!/
    end
    
    def go_back_to_article
      click_link 'a blog article'
      request.url.should == controller.show_url(Article.find_by_permalink('a-blog-article'))
    end
  end
end