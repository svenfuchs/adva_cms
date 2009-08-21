require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

if ActionController::Base.respond_to?(:tracks_url_history)
  module IntegrationTests
    module UrlHistoryTests
      class ArticleTest < ActionController::IntegrationTest
        def setup
          super
          @section = Page.find_by_title 'a page'
          @site = @section.site
          use_site! @site
          stub(Time).now.returns Time.utc(2008, 1, 2)
        end
        
        unless ApplicationController.tracks_url_history?
          test "without url_history: Admin publishes an article, views it, edits the permalink and gets 404" do
            login_as_admin
            visit_admin_articles_index_page
            create_and_publish_a_new_article
            visit "/articles/the-article-title"
            revise_the_article_permalink
            visit "/articles/the-article-title"
            assert_status 404
          end
        end

        if ApplicationController.tracks_url_history?
          test "with url_history: Admin publishes an article, views it, edits the permalink and gets redirected" do
            login_as_admin
            visit_admin_articles_index_page
            create_and_publish_a_new_article
            visit "/articles/the-article-title"
            assert_status 200
            request.url.should =~ %r(/articles/the-article-title)
            UrlHistory::Entry.recent_by_url(request.url).should_not be_nil

            revise_the_article_permalink
            visit "/articles/the-article-title"
            request.url.should =~ %r(/articles/article-permalink-updated)
          end
          
          # test is probably not relevant anymore since one cannot edit the
          # permalink in single-article-mode
          #
          # test "with url_history: Admin visits root page, edits primary article permalink, root page still works (single article mode)" do
          #   single_article_mode!
          #   login_as_admin
          #   visit "/"
          # 
          #   has_text @section.articles.primary.body
          #   revise_the_pages_primary_article_permalink
          #   visit "/"
          #   assert_status 200
          # end
        end

        def visit_admin_articles_index_page
          visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles"
        end

        def create_and_publish_a_new_article
          click_link "New"
          fill_in 'article[title]', :with => 'the article title'
          fill_in 'article[body]',  :with => 'the article body'
          select_date "2008-1-1",   :from => 'Publish on this date'
          click_button 'Save'

          request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
          @back_url = request.url
        end

        # def single_article_mode!
        #   @section.instance_variable_set(:@readonly, false) # WTF!
        #   @section.options[:single_article_mode] = true
        #   @section.save
        # end
        # 
        # def revise_the_pages_primary_article_permalink
        #   visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles/#{@section.articles.primary.id}/edit"
        #   fill_in 'article[permalink]', :with => 'page-primary-article-permalink-updated'
        #   click_button 'Save'
        #   request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
        # end

        def revise_the_article_permalink
          visit @back_url
          fill_in 'article[permalink]', :with => 'article-permalink-updated'
          click_button 'Save'
          request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
        end
      end
    end
  end
end