require File.dirname(__FILE__) + '/../spec_helper'

describe CommentsHelper do
  include Stubby, UrlMatchers, CommentsHelper

  before :each do
    stub_scenario :blog_with_published_article, :blog_comments
  end

  it '#comments_feed_title joins the titles of site, section and commentable' do
    helper.comments_feed_title(@site, @section, @article).should ==
      'Comments: site title &raquo; blog title &raquo; An article'
  end

  it '#link_to_remote_comment_preview returns a rote link to preview_comments_path' do
    helper.should_receive(:preview_comments_path).and_return '/path/to/comments/preview'
    helper.link_to_remote_comment_preview.should =~ /Ajax.Updater/
  end

  describe '#comment_form_hidden_fields returns hidden fields for generic comment form usage' do
    before :each do
      @fields = comment_form_hidden_fields(@article)
    end

    it 'including return_to' do
      @fields.should have_tag('input[type=?][name=?]', 'hidden', 'return_to')
    end

    it 'including comment[commentable_type]' do
      @fields.should have_tag('input[type=?][name=?]', 'hidden', 'comment[commentable_type]')
    end

    it 'including comment[commentable_id]' do
      @fields.should have_tag('input[type=?][name=?]', 'hidden', 'comment[commentable_id]')
    end
  end

  describe "the admin_comment_path helper" do
    it "calls admin_site_comment_path helper" do
      should_receive(:admin_site_comments_path)
      admin_comments_path
    end

    describe "with no :section_id param given" do
      describe "and with no :content_id param given" do
        it "returns the admin_site_comment_path with no further params" do
          stub!(:params).and_return :site_id => 1
          admin_comments_path(@site).should_not have_parameters
        end
      end

      describe "and with a :content_id param given" do
        it "returns the admin_site_comment_path with the :content_id param" do
          stub!(:params).and_return :site_id => 1, :content_id => 1
          admin_comments_path(@site).should have_parameters(:content_id)
        end
      end
    end

    describe "with a :section_id param given" do
      describe "and with no :content_id param given" do
        it "returns the admin_site_comment_path with the :section_id param" do
          stub!(:params).and_return :site_id => 1, :section_id => 1
          admin_comments_path(@site).should have_parameters(:section_id)
        end
      end

      describe "and with a :content_id param given" do
        it "returns the admin_site_comment_path with the :content_id param" do
          stub!(:params).and_return :site_id => 1, :section_id => 1, :content_id => 1
          admin_comments_path(@site).should have_parameters(:content_id)
        end
      end
    end
  end
end