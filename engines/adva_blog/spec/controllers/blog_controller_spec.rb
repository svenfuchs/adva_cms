require File.dirname(__FILE__) + '/../spec_helper'

describe BlogController do
  include SpecControllerHelper

  before do
    stub_scenario :blog_with_published_article
  end

  blog_paths          = %w( /blogs/1
                            /blogs/1/2000
                            /blogs/1/2000/1 )
  category_paths      = %w( /blogs/1/categories/foo
                            /blogs/1/categories/foo/2000
                            /blogs/1/categories/foo/2000/1 )
  tags_paths          = %w( /blogs/1/tags/tag-1+tag-2 )
  article_paths       = %w( /blogs/1/2000/1/1/an-article )
  articles_feed_paths = %w( /blogs/1.atom
                            /blogs/1/tags/foo+bar.atom ) # TODO what about categories?
  comments_feed_paths = %w( /blogs/1/comments.atom
                            /blogs/1/2008/1/1/an-article.atom )

  collection_paths = blog_paths + category_paths + tags_paths
  all_paths = collection_paths + article_paths

  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end

  all_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_gets_page_cached
    end
  end

  category_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_assigns :category
    end
  end

  collection_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_assigns :articles
      it_renders_template :index
    end
  end

  tags_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_assigns :tags, %(foo bar)
    end
  end

  article_paths.each do |path|
    describe "GET to #{path}" do
      before :each do
        @article.stub!(:published?).and_return true
      end
      act! { request_to :get, path }
      it_assigns :article

      describe "when the article is published" do
        it_renders_template :show
      end

      describe "when the article is not published" do
        before :each do
          @article.stub!(:published?).and_return false
          @article.stub!(:role_authorizing).and_return Rbac::Role.build(:author, :context => @article)
        end

        describe "and the user has :update permissions" do
          before :each do
            controller.stub!(:current_user).and_return stub_model(User, :has_role? => true)
          end

          it_renders_template :show
          it "skips caching for the rendered page" do
            act!
            controller.skip_caching?.should be_true
          end
        end

        describe "and the user does not have :update permissions" do
          before :each do
            controller.stub!(:current_user).and_return stub_model(User, :has_role? => false)
          end

          it "it returns a 404 status" do
            lambda { act! }.should raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end

  articles_feed_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_renders_template 'index', :format => :atom
      it_gets_page_cached
    end
  end

  comments_feed_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_renders_template 'comments/comments', :format => :atom
      it_gets_page_cached
    end
  end
end

describe "Blog page_caching" do
  include SpecControllerHelper

  describe BlogController do
    it "page_caches the :index action" do
      cached_page_filter_for(:index).should_not be_nil
    end

    it "tracks read access for a bunch of models for the :index action page caching" do
      BlogController.track_options[:index].should include('@article', '@articles', '@category', {'@site' => :tag_counts, '@section' => :tag_counts})
    end

    it "page_caches the :show action" do
      cached_page_filter_for(:show).should_not be_nil
    end

    it "tracks read access for a bunch of models for the :show action page caching" do
      BlogController.track_options[:show].should include('@article', '@articles', '@category', {"@section" => :tag_counts, "@site" => :tag_counts})
    end

    it "page_caches the comments action" do
      cached_page_filter_for(:comments).should_not be_nil
    end

    it "tracks read access on @commentable for comments action page caching" do
      BlogController.track_options[:comments].should include('@commentable')
    end
  end
end