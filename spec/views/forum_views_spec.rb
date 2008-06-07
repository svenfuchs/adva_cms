require File.dirname(__FILE__) + '/../spec_helper'

describe "Forum views:" do
  include SpecViewHelper
  include ContentHelper
  
  before :each do
    scenario :site, :user, :forum

    assigns[:site] = @site
    assigns[:section] = @forum
    assigns[:topics] = @topics

    # template.stub!(:links_to_content_categories).and_return 'links_to_content_categories'
    # template.stub!(:links_to_content_tags).and_return 'links_to_content_tags'
    # template.stub!(:link_to_content_comments).and_return 'link_to_content_comments'
    # template.stub!(:comment_path).and_return 'path/to/comment'
    
    template.stub!(:link_to_topic).and_return 'link_to_topic'
    template.stub!(:link_to_last_post).and_return 'link_to_last_post'
    template.stub!(:pluralize_str).and_return 'pluralized_str'
    template.stub!(:will_paginate).and_return 'will_paginate'
    
    template.stub_render hash_including(:partial => 'forum/topic')
  end
  
  describe "show view" do
    describe 'with an empty topics collection assigned' do
      before :each do
        assigns[:topics] = []
      end
      
      it 'shows a notice that no topics are present' do
        render "forum/show"
        response.body.should =~ /there are no topics/i
      end
      
      it 'shows a link to new_topic_path' do
        template.should_receive(:new_topic_path).and_return 'new_topic_path'
        render "forum/show"
      end
    end
    
    describe 'with an empty topics collection assigned' do
      it "renders the topic partial with the topics collection" do
        template.expect_render hash_including(:partial => 'topic', :collection => @topics)
        render "forum/show"
      end
    end
  end

  describe "the topic partial" do
    it "displays a link to the topic" do
      template.should_receive(:link_to_topic).and_return 'link_to_topic'
      render :partial => "forum/topic", :object => @topic
    end
    
    it "displays a link to the latest post" do
      template.should_receive(:link_to_last_postv).and_return 'link_to_last_post'
      render :partial => "forum/topic", :object => @topic
    end
    
    it "should display the topic's last_author_name" do
      @topic.should_receive(:last_author_name)
      render :partial => "forum/topic", :object => @topic
    end
  
    it "should display the topic's comment_count" do # TODO really should use a counter for that!
      @topic.comments.should_receive(:size)
      render :partial => "forum/topic", :object => @topic
    end
  end
end