require File.dirname(__FILE__) + '/../spec_helper'

describe "Section views:" do
  include SpecViewHelper
  include ContentHelper

  before :each do
    assigns[:site] = @site = stub_site
    assigns[:section] = @section = stub_section
    assigns[:comment] = @comment = stub_comment
    assigns[:article] = @article = stub_article

    template.stub!(:link_to_content).and_return 'link_to_content'
    template.stub!(:links_to_content_categories).and_return 'links_to_content_categories'
    template.stub!(:links_to_content_tags).and_return 'links_to_content_tags'
    template.stub!(:link_to_content_comments).and_return 'link_to_content_comments'
    template.stub!(:comment_path).and_return 'path/to/comment'

    template.stub!(:render).with hash_including(:partial => 'comments/list')
    template.stub!(:render).with hash_including(:partial => 'comments/form')
  end

  describe "show view" do
    before :each do
      assigns[:article] = @article
    end

    it "should render the article partial with an article in single mode" do
      template.should_receive(:render).with hash_including(:partial => 'article')
      render "sections/show"
    end

    it "should render the comments/list partial" do
      template.should_receive(:render).with hash_including(:partial => 'comments/list')
      render "sections/show"
    end

    describe "with an article that accepts comments" do
      it "should render the comments/form partial" do
        @article.should_receive(:accept_comments?).and_return true
        template.should_receive(:render).with hash_including(:partial => 'comments/form')
        render "sections/show"
      end
    end

    describe "with an article that does not accept comments" do
      it "should not render the comments/form partial" do
        @article.should_receive(:accept_comments?).and_return false
        template.should_not_receive(:render).with hash_including(:partial => 'comments/form')
        render "sections/show"
      end
    end
  end

  describe "the article partial" do
    it "should display the article" do
      render :partial => "sections/article", :object => @article
      response.should have_tag('div.entry')
    end

    it "should display the article's excerpt" do
      @article.should_receive(:excerpt_html)
      render :partial => "sections/article", :object => @article
    end

    it "should display the article's body" do
      @article.should_receive(:body_html)
      render :partial => "sections/article", :object => @article
    end

    it "should not display a 'read more' link" do
      template.should_not_receive(:link_to_content).with('Read the rest of this entry', @article)
      render :partial => "sections/article", :object => @article
      response.should_not have_tag('a', :text => /Read/)
    end
  end
end
