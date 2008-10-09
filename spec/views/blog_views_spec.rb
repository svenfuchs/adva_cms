require File.dirname(__FILE__) + '/../spec_helper'

describe "Blog views:" do
  include SpecViewHelper
  include ContentHelper

  before :each do
    Thread.current[:site] = stub_site

    assigns[:site] = stub_user
    assigns[:section] = stub_blog
    assigns[:comment] = stub_comment
    assigns[:article] = @article = stub_article

    template.stub!(:link_to_content).and_return 'link_to_content'
    template.stub!(:links_to_content_categories).and_return 'links_to_content_categories'
    template.stub!(:links_to_content_tags).and_return 'links_to_content_tags'
    template.stub!(:link_to_content_comments).and_return 'link_to_content_comments'
    template.stub!(:comment_path).and_return 'path/to/comment'
    template.stub!(:collection_title).and_return 'path/to/comment'
    template.stub!(:time_ago_in_words_with_microformat).and_return 'Once upon a time ...'

    template.stub_render hash_including(:partial => 'comments/list')
    template.stub_render hash_including(:partial => 'comments/form')
    template.stub_render hash_including(:partial => 'footer')
  end

  describe "index view" do
    before :each do
      assigns[:articles] = @articles = [@article, @article]
    end

    it "should render the article partial with a collection of articles in list mode" do
      template.expect_render :partial => 'article', :collection => @articles, :locals => {:mode => :many}
      render "blog/index"
    end
  end

  describe "show view" do
    before :each do
      assigns[:article] = @article
    end

    it "should render the article partial with an article in single mode" do
      template.expect_render hash_including(:partial => 'blog/article', :locals => {:mode => :single})
      render "blog/show"
    end

    it "should render the comments/list partial" do
      template.expect_render hash_including(:partial => 'comments/list')
      render "blog/show"
    end

    describe "with an article that accepts comments" do
      it "should render the comments/form partial" do
        @article.should_receive(:accept_comments?).and_return true
        template.expect_render hash_including(:partial => 'comments/form')
        render "blog/show"
      end
    end

    describe "with an article that does not accept comments" do
      it "should not render the comments/form partial" do
        @article.should_receive(:accept_comments?).and_return false
        template.should_not_receive(:render).with hash_including(:partial => 'comments/form')
        render "blog/show"
      end
    end
  end

  describe "the article partial" do
    before :each do
      assigns[:article] = @article
    end

    it "should display an article" do
      render :partial => "blog/article", :object => @article, :locals => {:mode => :many}
      response.should have_tag('div.entry')
    end

    it "should list the article's tags" do
      template.should_receive(:links_to_content_tags)
      render "blog/show"
    end

    it "should list the article's categories" do
      template.should_receive(:links_to_content_categories)
      render "blog/show"
    end

    describe "with an article that has an excerpt" do
      before :each do
        @article.should_receive(:has_excerpt?).at_least(1).times.and_return(true)
      end

      describe "in list mode" do
        it "should display the article's excerpt" do
          @article.should_receive(:excerpt_html)
          render :partial => "blog/article", :object => @article, :locals => {:mode => :many}
        end

        it "should not display the article's body" do
          @article.should_not_receive(:body_html)
          render :partial => "blog/article", :object => @article, :locals => {:mode => :many}
        end

        it "should display a 'read more' link" do
          template.should_receive(:link_to_content).with(@article)
          render :partial => "blog/article", :object => @article, :locals => {:mode => :many}
        end
      end

      describe "in single mode" do
        it "should display an article's excerpt" do
          @article.should_receive(:excerpt_html)
          render :partial => "blog/article", :object => @article, :locals => {:mode => :single}
        end

        it "should display the article's body" do
          @article.should_receive(:body_html)
          render :partial => "blog/article", :object => @article, :locals => {:mode => :single}
        end

        it "should not display a 'read more' link" do
          template.should_not_receive(:link_to_content).with('Read the rest of this entry', @article)
          render :partial => "blog/article", :object => @article, :locals => {:mode => :single}
          response.should_not have_tag('a', :text => /Read/)
        end
      end
    end

    describe "with an article that has no excerpt" do
      before :each do
        @article.should_receive(:has_excerpt?).at_least(1).times.and_return(false)
      end

      describe "in list mode" do
        it "should display the article's body" do
          @article.should_receive(:body_html)
          render :partial => "blog/article", :object => @article, :locals => {:mode => :many}
        end

        it "should not display a 'read more' link" do
          template.should_not_receive(:link_to_content).with('Read the rest of this entry', @article)
          render :partial => "blog/article", :object => @article, :locals => {:mode => :many}
        end
      end

      describe "in single mode" do
        it "should display the article's body" do
          @article.should_receive(:body_html)
          render :partial => "blog/article", :object => @article, :locals => {:mode => :single}
        end

        it "should not display a 'read more' link" do
          template.should_not_receive(:link_to_content).with('Read the rest of this entry', @article)
          render :partial => "blog/article", :object => @article, :locals => {:mode => :single}
          response.should_not have_tag('a', :text => /Read/)
        end
      end
    end
  end
end