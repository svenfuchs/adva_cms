require File.expand_path(File.dirname(__FILE__) + '/../test_helper' )

module IntegrationTests
  class BlogCategoriesTest < ActionController::IntegrationTest
    def setup
      super
      @section = Blog.first
      @site = @section.site
      use_site! @site
      @special_characters_category = @section.categories.find_by_title('$%&')
      @non_ascii_category = @section.categories.find_by_title('öäü')
      @section.categories.build(:title => 'uk').save
      @section.categories.build(:title => 'london').save
      @london = @section.categories.find_by_title('london')
      @uk     = @section.categories.find_by_title('uk')
      @london.move_to_child_of(@uk)
      @section.categories.update_paths!
    end
  
    test "user views categories of a blog that has nested categories" do
      login_as_user
      visit_blog_index
      
      if default_theme?
        visit_category(@uk)
        visit_category(@london)
      end
    end
    
    test "category with special characters permalink is accessible" do
      login_as_user
      visit_blog_index
      
      visit_category(@non_ascii_category) if default_theme?
    end
    
    # FIXME categories does not work with characters like $%&
    # test "category with special characters permalink is accessible" do
    #   login_as_user
    #   visit_blog_index
    #   visit_category(@special_characters_category)
    # end
    
    def visit_blog_index
      visit blog_path(@section)
      assert_template 'blogs/articles/index'
    end
    
    def visit_category(category)
      click_link category.title
      assert_template 'blogs/articles/index'
      assert_select 'h2.list_header', "Articles about #{category.title}"
    end
  end
end