require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class BlogIndexTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with blog'

      @published_article = Article.find_by_title 'a blog article'
      @unpublished_article = Article.find_by_title 'an unpublished blog article'
    
      @category = Category.find_by_title 'a blog category'
      @another_category = Category.find_by_title 'another blog category'
    end
  
    test "User clicks through blog frontend blog index pages" do
      visits_blog_index 
    
      visits_blog_category_index 
      visits_empty_blog_category_index
    
      visits_blog_tag_index
      visits_missing_blog_tag_index
    
      visits_blog_this_years_archive_index
      visits_blog_last_years_archive_index
    
      visits_blog_this_months_archive_index
      visits_blog_last_months_archive_index
    end
  
    def visits_blog_index
      get "/"
    
      renders_template "blogs/articles/index"
      displays_article @published_article
      does_not_display_article @unpublished_article
    end
  
    def visits_blog_category_index
      get 'categories/a-category'
      # click_link 'a category'
    
      renders_template "blogs/articles/index"
      displays_article @published_article
      does_not_display_article @unpublished_article
    end
  
    def visits_empty_blog_category_index
      get 'categories/another-category'
      # click_link 'another category' # FIXME webrat seems to be confused about the current session

      renders_template "blogs/articles/index"
      does_not_display_article @published_article
      does_not_display_article @unpublished_article
    end
  
    def visits_blog_tag_index
      get "/tags/foo"
    
      renders_template "blogs/articles/index"
      displays_article @published_article
      does_not_display_article @unpublished_article
    end
  
    def visits_missing_blog_tag_index
      get "/tags/does-not-exist"

      assert_status 404
    end
  
    def visits_blog_this_years_archive_index
      get "/2008"
    
      renders_template "blogs/articles/index"
      displays_article @published_article
      does_not_display_article @unpublished_article
    end

    def visits_blog_last_years_archive_index
      get "/2007"
    
      renders_template "blogs/articles/index"
      does_not_display_article @published_article
      does_not_display_article @unpublished_article
    end
  
    def visits_blog_this_months_archive_index
      get "/2008/1"
    
      renders_template "blogs/articles/index"
      displays_article @published_article
      does_not_display_article @unpublished_article
    end
  
    def visits_blog_last_months_archive_index
      get "/2007/12"
    
      renders_template "blogs/articles/index"
      does_not_display_article @published_article
      does_not_display_article @unpublished_article
    end
  end
end