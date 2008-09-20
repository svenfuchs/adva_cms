require File.dirname(__FILE__) + '/../spec_helper'

describe "Post views:" do
  include SpecViewHelper
  include ContentHelper

  before :each do
    assigns[:section] = @forum = stub_forum
    assigns[:topic] = @topic = stub_topic
    assigns[:post] = @post = stub_comment

    Section.stub!(:find).and_return @forum

    template.stub_render hash_including(:partial => 'posts/form')
  end

  describe "the new view" do
    before :each do
      template.stub!(:topic_posts_path).and_return 'topic_posts_path'
      template.stub!(:submit_tag).and_return 'submit_tag'
      template.stub!(:link_to_remote_comment_preview).and_return 'link_to_remote_comment_preview'
    end

    # it "renders the topics/form partial" do
    #   template.expect_render hash_including(:partial => 'form')
    #   render "posts/new"
    # end

    it "should be fixed"
  end

  describe "the edit view" do
  #    before :each do
  #      template.stub!(:topic_path).and_return 'topics_path'
  #      template.stub!(:link_to_remote_comment_preview).and_return 'link_to_remote_comment_preview'
  #    end
  #
  #    it "renders the topics/form partial" do
  #      template.expect_render hash_including(:partial => 'form')
  #      render "topics/edit"
  #    end
    it "should be fixed"
  end

  describe "the posts/form partial" do
    before :each do
      @post.stub!(:author).and_return Anonymous.new
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:topic, @topic, template, {}, nil)
      template.stub!(:topic_posts_path).and_return 'topic_posts_path'
    end

    it "renders form inputs for topic attributes" do
      render "posts/_form"
      response.should have_tag('textarea[name=?]', 'post[body]')
    end

    it "renders form inputs for an anonymous author" do
      render "posts/_form"
      response.should have_tag('input[name=?]', 'anonymous[name]')
      response.should have_tag('input[name=?]', 'anonymous[email]')
    end
  end
end