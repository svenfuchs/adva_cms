require File.dirname(__FILE__) + '/../../test_helper'

class CommentsHelperTest < ActionView::TestCase
  include CommentsHelper

  attr_accessor :request

  def setup
    super
    @section = Section.first
    @article = @section.articles.first
    @site = @section.site

    stub(self).protect_against_forgery?.returns false

    TestController.send :include, CommentsHelper
    @controller = TestController.new
    @request = ActionController::TestRequest.new
  end

  test '#comments_feed_title joins the titles of site, section and commentable' do
    comments_feed_title(@site, @section, @article).should ==
      "Comments: #{@site.title} &raquo; #{@section.title} &raquo; #{@article.title}"
  end

  # test '#link_to_remote_comment_preview returns a rote link to preview_comments_path' do
  #   mock(self).preview_comments_path.returns '/path/to/comments/preview'
  #   link_to_remote_comment_preview.should =~ /Ajax.Updater/
  # end

  # comment_form_hidden_fields

  test '#comment_form_hidden_fields includes a hidden return_to field' do
    result = comment_form_hidden_fields(@article)
    result.should have_tag('input[type=?][name=?]', 'hidden', 'return_to')
  end

  test 'including comment[commentable_type]' do
    result = comment_form_hidden_fields(@article)
    result.should have_tag('input[type=?][name=?]', 'hidden', 'comment[commentable_type]')
  end

  test 'including comment[commentable_id]' do
    result = comment_form_hidden_fields(@article)
    result.should have_tag('input[type=?][name=?]', 'hidden', 'comment[commentable_id]')
  end

  test "#admin_comment_path with no :section_id param given and with no :content_id param given
        it returns the admin_site_comment_path with no further params" do
    @controller.params = { :site_id => 1 }
    @controller.admin_comments_path(@site).should_not have_url_params
  end

  test "#admin_comment_path  with no :section_id param given and with a :content_id param given
        it returns the admin_site_comment_path with the :content_id param" do
    @controller.params = { :site_id => 1, :content_id => 1 }
    @controller.admin_comments_path(@site).should have_url_params(:content_id)
  end

  test "#admin_comment_path with a :section_id param given and with no :content_id param given
        it returns the admin_site_comment_path with the :section_id param" do
    @controller.params = { :site_id => 1, :section_id => 1 }
    @controller.admin_comments_path(@site).should have_url_params(:section_id)
  end

  test "#admin_comment_path with a :section_id param given and with a :content_id param given
        it returns the admin_site_comment_path with the :content_id param" do
    @controller.params = { :site_id => 1, :section_id => 1, :content_id => 1 }
    @controller.admin_comments_path(@site).should have_url_params(:content_id)
  end
end

class LinkToCommentsHelperTest < ActionView::TestCase
  include ContentHelper, ResourceHelper
  tests CommentsHelper

  def setup
    super
    @section = Section.first
    @article = @section.articles.find_by_title 'a page article'
    @category = @section.categories.first
    @tag = Tag.new :name => 'foo'

    stub(self).current_controller_namespace.returns(nil) # yuck
    @article_path = show_path(@article)
  end

  # link_to_content_comments_count

  test "#link_to_content_comments_count returns a link_to_content_comments" do
    link_to_content_comments_count(@article).should have_tag('a[href=?]', "#{@article_path}#comments")
  end

  test "#link_to_content_comments_count given the option :total is set
        it returns a link_to_content_comments with the approved and total comments counts as a link text" do
    link_to_content_comments_count(@article, :total => true).should =~ /\d{2} \(\d{2}\)/
  end

  test "#link_to_content_comments_count given the option :total is not set
        it returns a link_to_content_comments with the total comments count as a link text" do
    link_to_content_comments_count(@article).should =~ /\d{2}/
  end

  test "#link_to_content_comments_count given the content has no comments
        it returns the option :alt as plain text" do
    stub(@article).approved_comments_count.returns 0
    link_to_content_comments_count(@article, :alt => 'no comments').should == 'no comments'
  end

  test "#link_to_content_comments_count given the content has no comments and no option :alt was passed
        it returns 'none' as plain text" do
    stub(@article).approved_comments_count.returns 0
    link_to_content_comments_count(@article).should == 'none'
  end

  # link_to_content_comments

  test "#link_to_content_comments given a content it returns a link to show_path" do
    link_to_content_comments(@article).should have_tag('a[href=?]', "#{@article_path}#comments", '1 Comment')
  end

  test "#link_to_content_comments given a content and a comment it returns a link to show_path + comment anchor" do
    comment = @article.comments.first
    anchor = dom_id(comment)
    link_to_content_comments(@article, comment).should == %(<a href="#{@article_path}##{anchor}">1 Comment</a>)
  end

  test "#link_to_content_comments given the first arg is a String it uses the String as link text" do
    path = show_path(@article)
    link_to_content_comments('link text', @article).should == %(<a href="#{path}#comments">link text</a>)
  end

  test "#link_to_content_comments given the content has no approved comments and the content does not accept comments
        it returns nil" do
    mock(@article).approved_comments_count.returns 0
    mock(@article).accept_comments?.returns false
    link_to_content_comments(@article).should be_nil
  end

  # link_to_content_comment

  test "#link_to_content_comment inserts the comment's commentable to the args and calls link_to_content_comments" do
    comment = @article.comments.first
    anchor = dom_id(comment)
    link_to_content_comment(comment).should == %(<a href="#{@article_path}##{anchor}">1 Comment</a>)
  end
end