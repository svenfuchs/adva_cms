require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminBlogArticleTest < ActionController::IntegrationTest
    def setup
      super
      @section = Blog.first
      @site = @section.site
      use_site! @site
      stub(Time).now.returns Time.utc(2008, 1, 1)
    end
  
    test "Admin creates an article, previews, edits and deletes it" do
      login_as_admin
      visit_admin_articles_index_page
      create_a_new_article
      revise_the_article
      preview_article
      delete_article
    end

    def visit_admin_articles_index_page
      visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles"
    end

    def create_a_new_article
      click_link "New"
      fill_in 'article[title]', :with => 'the article title'
      fill_in 'article[body]',  :with => 'the article body'
      click_button 'Save'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
    end

    def revise_the_article
      fill_in 'article[title]', :with => 'the revised article title'
      fill_in 'article[body]',  :with => 'the revised article body'
      click_button 'Save'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
      @back_url = request.url
    end

    def preview_article
      click_link 'Show'
      request.url.should == controller.show_url(Article.find_by_permalink('the-article-title'))
    end

    def delete_article
      visit @back_url
      click_link 'Delete'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles)
      response.body.should_not =~ %r(the revised article title)
    end
  end
end