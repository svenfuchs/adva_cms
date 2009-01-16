require File.dirname(__FILE__) + '/../spec_helper'

describe SectionsController do
  include SpecControllerHelper

  before :each do
    stub_scenario :section_with_published_article
  end

  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end

  describe "GET to :show" do
    before :each do
      @article.stub!(:published?).and_return true
    end
    act! { request_to :get, '/sections/1' }
    it_assigns :section, :article

    describe "with no article permalink given" do
      it_renders_template :show
      it_gets_page_cached

      it "should find the section's primary article" do
        @section.articles.should_receive(:primary).any_number_of_times.and_return @article
        act!
      end
    end

    describe "with an article permalink given" do
      act! { request_to :get, '/sections/1/articles/an-article' }

      it "should find the section's primary article" do
        @section.articles.should_receive(:find_by_permalink).any_number_of_times.and_return @article
        act!
      end

      describe "when the article is published" do
        it_renders_template :show
        it_gets_page_cached
      end

      describe "when the article is not published" do
        before :each do
          @article.stub!(:draft?).and_return true
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
          it_redirects_to { login_url(:return_to => request.url) }
        end
      end
    end
  end
end

describe SectionsController, 'feeds' do
  include SpecControllerHelper

  before :each do
    stub_scenario :section_with_published_article
  end

  comments_paths = %w( /sections/1/comments.atom
                       /sections/1/articles/an-article.atom)

  comments_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_renders_template 'comments/comments', :format => :atom
      it_gets_page_cached
    end
  end
end

describe SectionsController, "page_caching" do
  include SpecControllerHelper

  it "page_caches the show action" do
    cached_page_filter_for(:show).should_not be_nil
  end

  it "tracks read access on @article for show action page caching" do
    SectionsController.track_options[:show].should include('@article')
  end

  it "page_caches the comments action" do
    cached_page_filter_for(:comments).should_not be_nil
  end

  it "tracks read access on @commentable for comments action page caching" do
    SectionsController.track_options[:comments].should include('@commentable')
  end
end
