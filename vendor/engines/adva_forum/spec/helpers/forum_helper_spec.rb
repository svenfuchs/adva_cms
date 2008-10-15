require File.dirname(__FILE__) + '/../spec_helper'

describe ForumHelper do
  include Stubby

  before :each do
    scenario :forum_with_topics
    helper.stub!(:topic_path).and_return 'path/to/topic'
    helper.extend(BaseHelper)
  end

  describe "#link_to_topic" do
    it "links to the given topic" do
      helper.link_to_topic(@topic).should have_tag('a[href=?]', 'path/to/topic')
    end

    it "given no String preceeds the topic in the argument list it uses the topic's title as link text" do
      helper.should_receive(:link_to).with('a topic', 'path/to/topic', {})
      helper.link_to_topic @topic
    end

    it "given a String preceeding the topic in the argument list uses the String as link text" do
      helper.should_receive(:link_to).with('link text', 'path/to/topic', {})
      helper.link_to_topic 'link text', @topic
    end
  end

  describe "#link_to_last_post" do
    it "links to the last post of a topic" do
      helper.link_to_last_post(@topic).should have_tag('a[href=?]', 'path/to/topic')
    end

    it "given no String preceeds the topic in the argument list it uses the last comment's created_at date as link text" do
      helper.link_to_last_post(@topic).should =~ /[\w]+ [\d]+, [\d]+\ [\d]+\:[\d]+/
    end

    it "given a String preceeding the topic in the argument list uses the String as link text" do
      helper.link_to_last_post('link text', @topic).should =~ /link text/
    end
  end

  describe "#link_to_prev_topic" do
    before :each do
      helper.stub!(:previous_topic_path).and_return('previous_topic_path')
    end

    it "links to the previous topic" do
      helper.link_to_prev_topic(@topic).should have_tag('a[href=?]', 'previous_topic_path')
    end

    it "given no String preceeds the topic in the argument list it uses '&larr; previous' as link text" do
      helper.link_to_prev_topic(@topic).should =~ /&larr; previous/
    end

    it "given a String preceeding the topic in the argument list uses the String as link text" do
      helper.link_to_prev_topic('link text', @topic).should =~ /link text/
    end

    it "given a :format option interpolates the links to it" do
      helper.link_to_prev_topic(@topic, {:format => '<b>%s</b>'}).should =~ %r(<b>.*</b>)
    end
  end

  describe "#link_to_next_topic" do
    before :each do
      helper.stub!(:next_topic_path).and_return('next_topic_path')
    end

    it "links to the next topic" do
      helper.link_to_next_topic(@topic).should have_tag('a[href=?]', 'next_topic_path')
    end

    it "given no String preceeds the topic in the argument list it uses 'next &rarr;' as link text" do
      helper.link_to_next_topic(@topic).should =~ /next &rarr;/
    end

    it "given a String preceeding the topic in the argument list uses the String as link text" do
      helper.link_to_next_topic('link text', @topic).should =~ /link text/
    end

    it "given a :format option interpolates the links to it" do
      helper.link_to_next_topic(@topic, {:format => '<b>%s</b>'}).should =~ %r(<b>.*</b>)
    end
  end

  describe "#links_to_prev_next_topics" do
    before :each do
      helper.stub!(:link_to_prev_topic).and_return('link_to_prev_topic')
      helper.stub!(:link_to_next_topic).and_return('link_to_next_topic')
    end

    it "returns links to the the previous and next topics" do
      helper.should_receive(:link_to_prev_topic).and_return('link_to_prev_topic')
      helper.should_receive(:link_to_next_topic).and_return('link_to_next_topic')
      helper.links_to_prev_next_topics @topic
    end

    it "given no :separator option it uses a space to join the links" do
      helper.links_to_prev_next_topics(@topic).should == 'link_to_prev_topic link_to_next_topic'
    end

    it "given an option :separator it uses that to join the links" do
      helper.links_to_prev_next_topics(@topic, :separator => ' + ').should == 'link_to_prev_topic + link_to_next_topic'
    end

    it "given a :format option interpolates the links to it" do
      helper.links_to_prev_next_topics(@topic, :format => '<b>%s</b>').should == '<b>link_to_prev_topic link_to_next_topic</b>'
    end
  end

  describe "#topic_attributes" do
    before :each do
      @topic.stub!(:comments_count).and_return 2
    end

    it "returns comma-joined meta data about the topic including the number of posts" do
      helper.topic_attributes(@topic).should =~ /2 posts/
    end

    it "given that the topic is sticky also includes the string 'sticky'" do
      @topic.stub!(:sticky?).and_return true
      helper.topic_attributes(@topic).should =~ /sticky/
    end

    it "given that the topic is not sticky does not include the string 'sticky'" do
      helper.topic_attributes(@topic).should_not =~ /sticky/
    end

    it "given that the topic is locked also includes the string 'locked'" do
      @topic.stub!(:locked?).and_return true
      helper.topic_attributes(@topic).should =~ /locked/
    end

    it "given that the topic is not locked does not include the string 'locked'" do
      helper.topic_attributes(@topic).should_not =~ /locked/
    end

    it "given a format_string as second argument it interpolates the result to it" do
      helper.topic_attributes(@topic, '<b>%s</b>').should !~ %r(<b>.*</b>)
    end
  end
end