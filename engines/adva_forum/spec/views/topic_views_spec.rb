require File.dirname(__FILE__) + '/../spec_helper'

describe "Topic views:" do
  include SpecViewHelper
  include ContentHelper

  before :each do
    assigns[:site]    = @site = stub_site
    assigns[:section] = @forum = stub_forum
    assigns[:topic]   = @topic = stub_topic
    @post             = stub_comment
    @board            = stub_board
    @topic.stub!(:initial_post).and_return Post.new
    
    Section.stub!(:find).and_return @forum

    template.stub!(:topic_attributes).and_return 'topic_attributes'
    template.stub!(:authorized_tag).and_return 'authorized_tag'
    template.stub!(:link_to_prev_topic).and_return 'link_to_prev_topic'
    template.stub!(:link_to_next_topic).and_return 'link_to_next_topic'
    template.stub!(:will_paginate).and_return 'will_paginate'

    template.stub!(:render).with hash_including(:partial => 'topics/post')
    template.stub!(:render).with hash_including(:partial => 'posts/form')
  end

  describe "the show view" do
    before :each do
      assigns[:post] = @post = Post.new
    end
    
    it "shows the topic title" do
      @topic.should_receive(:title).and_return 'the topic title'
      render "topics/show"
      response.should have_text(/the topic title/)
    end

    it "shows the topic attributes (e.g. locked, sticky, post count)" do
      template.should_receive(:topic_attributes)
      render "topics/show"
    end

    it "renders the topics/post partial with the posts collection" do
      template.should_receive(:render).with hash_including(:partial => 'topics/post')
      render "topics/show"
    end

    it "shows an authorized tag with the topic edit link" do
      template.should_receive(:authorized_tag).once.with(:span, :update, @topic)
      render "topics/show"
    end

    it "shows an authorized tag with the topic delete link" do
      template.should_receive(:authorized_tag).once.with(:span, :destroy, @topic)
      render "topics/show"
    end
    
    it "shows an authorized tag with the post create form" do
      template.should_receive(:authorized_tag).once.with(:span, :create, @post)
      render "topics/show"
    end

    # TODO fix authorized_tag first
    it "renders the posts/form" #do
    #   template.should_receive(:render).with hash_including(:partial => 'posts/form')
    #   render "topics/show"
    # end
  end

  describe "the new view" do
    before :each do
      template.stub!(:topics_path).and_return 'topics_path'
      template.stub!(:error_messages_for).and_return 'error_messages_for' # TODO really should not be used, boy
      template.stub!(:link_to_remote_comment_preview).and_return 'link_to_remote_comment_preview'
    end

    it "renders the topics/form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      render "topics/new"
    end
  end

  describe "the edit view" do
    before :each do
      template.stub!(:topic_path).and_return 'topics_path'
      template.stub!(:link_to_remote_comment_preview).and_return 'link_to_remote_comment_preview'
    end

    it "renders the topics/form partial" do
      template.should_receive(:render).with hash_including(:partial => 'form')
      render "topics/edit"
    end
  end

  describe "the topics/post partial" do
    before :each do
      template.stub!(:post).and_return @post
      template.stub!(:gravatar_img).and_return 'gravatar_img'
    end

    it "shows the post body html" do
      @post.should_receive(:body_html).and_return 'the post body html'
      render "topics/_post"
      response.should have_text(/the post body html/)
    end

    it "shows an authorized tag with the topic edit link" do
      template.should_receive(:authorized_tag).with(:span, :update, @post)
      render "topics/_post"
    end

    it "shows an authorized tag with the topic delete link" do
      template.should_receive(:authorized_tag).with(:span, :destroy, @post)
      render "topics/_post"
    end
    
    it "does not show an authorized tag with the topic delete link if post is initial post" do
      @topic.stub!(:initial_post).and_return @post
      template.should_not_receive(:authorized_tag).with(:span, :destroy, @post)
      render "topics/_post"
    end
  end

  describe "the topics/form partial" do
    before :each do
      template.stub!(:f).and_return ActionView::Base.default_form_builder.new(:topic, @topic, template, {}, nil)
      @topic.stub!(:author).and_return User.new
    end

    it "renders form inputs for topic attributes" do
      render "topics/_form"
      response.should have_tag('input[name=?]', 'topic[title]')
    end

    it "renders form inputs for an anonymous author" do
      render "topics/_form"
      response.should have_tag('input[name=?]', 'user[name]')
      response.should have_tag('input[name=?]', 'user[email]')
    end

    it "shows an authorized tag with the topic moderation options (sticky, lock)" do
      template.should_receive(:authorized_tag).with(:p, :moderate, @topic)
      render "topics/_form"
    end
  end
end
