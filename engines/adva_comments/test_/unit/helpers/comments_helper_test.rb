require File.dirname(__FILE__) + '/../../test_helper'

class CommentsHelperTest < ActiveSupport::TestCase
  include CommentsHelper

  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::JavaScriptHelper
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper

  def setup
    super
    @section = Section.first
    @article = @section.articles.first
    @site = @section.site
    
    stub(self).protect_against_forgery?.returns false
    stub(self).request.returns ActionController::TestRequest.new
  end

  test '#comments_feed_title joins the titles of site, section and commentable' do
    comments_feed_title(@site, @section, @article).should ==
      "Comments: #{@site.title} &raquo; #{@section.title} &raquo; #{@article.title}"
  end

  test '#link_to_remote_comment_preview returns a rote link to preview_comments_path' do
    mock(self).preview_comments_path.returns '/path/to/comments/preview'
    link_to_remote_comment_preview.should =~ /Ajax.Updater/
  end
  
  # comment_form_hidden_fields

  test '#comment_form_hidden_fields includes a hidden return_to field' do
    result = comment_form_hidden_fields(@article)
    # FIXME implement matcher
    # result.should have_tag('input[type=?][name=?]', 'hidden', 'return_to')
  end

  test 'including comment[commentable_type]' do
    result = comment_form_hidden_fields(@article)
    # FIXME implement matcher
    # result.should have_tag('input[type=?][name=?]', 'hidden', 'comment[commentable_type]')
  end

  test 'including comment[commentable_id]' do
    result = comment_form_hidden_fields(@article)
    # FIXME implement matcher
    # result.should have_tag('input[type=?][name=?]', 'hidden', 'comment[commentable_id]')
  end

  test "#admin_comment_path with no :section_id param given and with no :content_id param given
        it returns the admin_site_comment_path with no further params" do
    stub(self).params.returns :site_id => 1
    # FIXME implement matcher
    # admin_comments_path(@site).should_not have_parameters
  end

  test "#admin_comment_path  with no :section_id param given and with a :content_id param given
        it returns the admin_site_comment_path with the :content_id param" do
    stub(self).params.returns :site_id => 1, :content_id => 1
    # FIXME implement matcher
    # admin_comments_path(@site).should have_parameters(:content_id)
  end

  test "#admin_comment_path with a :section_id param given and with no :content_id param given
        it returns the admin_site_comment_path with the :section_id param" do
    stub(self).params.returns :site_id => 1, :section_id => 1
    # FIXME implement matcher
    # admin_comments_path(@site).should have_parameters(:section_id)
  end

  test "#admin_comment_path with a :section_id param given and with a :content_id param given
        it returns the admin_site_comment_path with the :content_id param" do
    stub(self).params.returns :site_id => 1, :section_id => 1, :content_id => 1
    # FIXME implement matcher
    # admin_comments_path(@site).should have_parameters(:content_id)
  end
end