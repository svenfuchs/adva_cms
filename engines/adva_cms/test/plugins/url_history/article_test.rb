require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )
require File.expand_path(File.dirname(__FILE__) + '/test_helper' )

Content.class_eval do
  def update_url_history_params(params)
    if params.has_key?(:year)
      params.merge self.full_permalink
    elsif params.has_key?(:permalink)
      params.merge :permalink => self.permalink
    else
      params
    end
  end
end

module IntegrationTests
  module UrlHistory
    class ArticleTest < ActionController::IntegrationTest
      include UrlHistoryTestHelper
    
      def setup
        super
        @section = Section.find_by_title 'a section'
        @site = @section.site
        use_site! @site
        stub(Time).now.returns Time.utc(2008, 1, 2)
      end

      test "without url_history: Admin publishes an article, views it, edits the permalink and gets 404" do
        uninstall_url_history!
        login_as_admin
        visit_admin_articles_index_page
        create_and_publish_a_new_article
        visit "/articles/the-article-title"
        revise_the_article_permalink
        visit "/articles/the-article-title"
        assert_status 404
      end
      
      test "with url_history: Admin publishes an article, views it, edits the permalink and gets redirected" do
        install_url_history!
        login_as_admin
        visit_admin_articles_index_page
        create_and_publish_a_new_article
        visit "/articles/the-article-title"
        revise_the_article_permalink
        visit "/articles/the-article-title"
        request.url.should =~ %r(/articles/article-permalink-updated)
      end
      
      test "with url_history: Admin visits root section, edits primary article permalink, root section still works" do
        uninstall_url_history!
        login_as_admin
        visit "/"
        has_text @section.articles.primary.body
        revise_the_sections_primary_article_permalink
        visit "/"
        assert_status 200
      end

      def visit_admin_articles_index_page
        visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles"
      end

      def create_and_publish_a_new_article
        click_link "Create a new article"
        fill_in 'article[title]', :with => 'the article title'
        fill_in 'article[body]',  :with => 'the article body'
        select_date "2008-1-1",   :from => 'Publish on this date'
        click_button 'Save'

        request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
        @back_url = request.url
      end
    
      def revise_the_sections_primary_article_permalink
        visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles/#{@section.articles.primary.id}/edit"
        fill_in 'article[permalink]', :with => 'section-primary-article-permalink-updated'
        click_button 'Save'
        request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
      end

      def revise_the_article_permalink
        visit @back_url
        fill_in 'article[permalink]', :with => 'article-permalink-updated'
        click_button 'Save'
        request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
      end
    end
  end
end