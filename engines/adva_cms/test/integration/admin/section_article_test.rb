require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminSectionArticleTest < ActionController::IntegrationTest
    def setup
      super
      @section = Section.find_by_title 'a section'
      @site = @section.site

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
      assert_equal :de, Article.locale
      revise_the_de_article
      preview_de_article
      delete_article
    end
    
    test "editing a German article in English interface" do
      login_as_admin
      visit_admin_articles_index_page
      click_link 'a section article'
      assert_select 'input#article_title[value="a section article"]'
      assert_select '#article_body', 'a section article body'
      visit '/admin/sites/1/sections/1/articles/1/edit?cl=de'
      assert_response :success 
      assert_equal :de, Article.locale
      assert_select 'input#article_title[value="a section article"]'
      assert_select '#article_body', 'a section article body'
      fill_in 'article[body]',  :with => 'a section article body in de'
      click_button 'Save'
      assert_equal 'a section article body in de', Article.find(1).body
      assert_equal 'de', @controller.params[:cl]
      assert_response :success
      assert_equal :de, Article.locale
      assert_select 'input#article_title[value="a section article"]'

#     Something weird going on here -- assert_select has something different than @response.body
#      puts @response.body
#      assert_select('form fieldset:first-of-type') do |f|
#        assert_select('textarea#article_body', 'a section article body in de', f)
#      end
#      assert_select @response.body, 'textarea#article_body', 'a section article body in de'
    end
    
    def visit_admin_articles_index_page
      visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles"
    end

    def create_a_new_article
      click_link "Create a new article"
      fill_in 'article[title]', :with => 'the article title'
      fill_in 'article[body]',  :with => 'the article body'
      click_button 'Save'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles/\d+/edit)
    end

    def create_a_new_de_article
      click_link "Create a new article"
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
      click_link 'Preview this article'
      request.url.should == "http://#{@site.host}/articles/the-article-title?cl=en"
    end

    def preview_de_article
      click_link 'Preview this article'
      request.url.should == "http://#{@site.host}/articles/the-article-title-de?cl=de"
    end

    def delete_article
      visit @back_url
      click_link 'Delete this article'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/articles)
      response.body.should_not =~ %r(the revised article title)
    end
  end
end