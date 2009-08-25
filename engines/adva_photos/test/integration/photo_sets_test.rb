require File.expand_path(File.dirname(__FILE__) + '/../test_helper' )

module IntegrationTests
  class PhotoSetsTest < ActionController::IntegrationTest
    def setup
      super
      @section = Album.first
      @site = @section.site
      use_site! @site
      @section.categories.build(:title => 'uk').save
      @section.categories.build(:title => 'london').save
      @london = @section.categories.find_by_title('london')
      @uk     = @section.categories.find_by_title('uk')
      @london.move_to_child_of(@uk)
      @section.categories.update_paths!
    end
  
    test "user views categories of an album that has nested categories" do
      login_as_user
      visit_album_index
      if default_theme?
        visit_category(@uk)
        visit_category(@london)
      end
    end
    
    def visit_album_index
      visit album_path(@section)
      assert_template 'albums/index'
    end
    
    def visit_category(category)
      click_link category.title
      assert_template 'albums/index'
      assert_select 'h2.list_header', "Photos about #{category.title}"
    end
  end
end