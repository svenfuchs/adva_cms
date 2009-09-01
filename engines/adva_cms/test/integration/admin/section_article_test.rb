require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminSectionArticleTest < ActionController::IntegrationTest
    def setup
      super
      @section = Page.find_by_title 'a page'
      @site = @section.site
      @article = @section.articles.first

      use_site! @site
      stub(Time).now.returns Time.utc(2008, 1, 2)
    end

    # FIXME add reordering articles
    test "Admin creates an article, previews, edits and deletes it" do
      login_as_admin
      visit_admin_articles_index_page
      create_a_new_article
      revise_the_article
      preview_article
      delete_article
    end
    
    test "posting a German article in English interface" do
      login_as_admin
      visit_admin_articles_index_page
      create_a_new_de_article
      revise_the_de_article
      preview_de_article
      delete_article
    end
    
    test "categories are not selectable in single article mode" do
      login_as_admin
      section_in_single_article_mode
      visit_admin_article_edit_page
      assert_select "ul[class=categories]", false
    end
    
    test "categories are selectable in multi article mode" do
      login_as_admin
      section_in_multi_article_mode
      visit_admin_article_edit_page
      assert_select "ul[class=categories]"
    end

    test "editing a German article in English interface" do
      login_as_admin
      visit_admin_articles_index_page

      click_link 'a page article'
      assert_select 'input#article_title[value="a page article"]'
      assert_select '#article_body', 'a page article body'

      article = Article.find_by_title 'a page article'
      visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles/#{article.id}/edit?cl=de"
      assert_response :success
      assert_select 'input#article_title[value="a page article"]'
      assert_select '#article_body', 'a page article body'
      fill_in 'article[body]',  :with => 'a page article body in de'
      click_button 'Save'

      assert_equal 'de', @controller.params[:cl]
      assert_response :success
      assert_select 'input#article_title[value="a page article"]'

#     Something weird going on here -- assert_select has something different than @response.body
#      puts @response.body
#      assert_select('form fieldset:first-of-type') do |f|
#        assert_select('textarea#article_body', 'a page article body in de', f)
#      end
#      assert_select @response.body, 'textarea#article_body', 'a page article body in de'
    end

    def visit_admin_articles_index_page
      visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles"
    end
    
    def visit_admin_article_edit_page
      visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles/#{@article.id}/edit"
      assert_template 'admin/articles/edit'
    end
    
    def section_in_single_article_mode
      # FIXME why is section readonly ?
      Site.stubs(:find).returns @site
      @site.sections.stubs(:find).returns @section
      @section.stubs(:single_article_mode).returns true
    end
    
    def section_in_multi_article_mode
      # FIXME why is section readonly ?
      Site.stubs(:find).returns @site
      @site.sections.stubs(:find).returns @section
      @section.stubs(:single_article_mode).returns false
    end
    
    def create_a_new_article
      click_link "New"
      fill_in 'article[title]', :with => 'the article title'
      fill_in 'article[body]',  :with => 'the article body'
      click_button 'Save'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
    end

    def create_a_new_de_article
      click_link "New"
      select 'de', :from => 'content_locale'
      assert_response :success
      fill_in 'article[title]', :with => 'the article title [de]'
      fill_in 'article[body]',  :with => 'the article body [de]'
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

    def revise_the_de_article
      fill_in 'article[title]', :with => 'the revised article title [de]'
      fill_in 'article[body]',  :with => 'the revised article body [de]'
      click_button 'Save'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
      @back_url = request.url
    end

    def preview_article
      click_link 'Show'
      request.url.should == controller.show_url(Article.find_by_permalink('the-article-title'))
    end

    def preview_de_article
      click_link 'Show'
      request.url.should == controller.show_url(Article.find_by_permalink('the-article-title-de'), :cl => :de)
    end

    def delete_article
      visit @back_url
      click_link 'Delete'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles)
      response.body.should_not =~ %r(the revised article title)
    end
  end
end