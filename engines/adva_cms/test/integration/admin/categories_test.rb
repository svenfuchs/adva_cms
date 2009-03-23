require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminCategoriesTest < ActionController::IntegrationTest
    def setup
      super
      @section = Page.find_by_title 'a page'
      @site = @section.site
      use_site! @site
    end

    test "Admin creates a category, changes the title and deletes it" do
      login_as_admin
      visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles"
      create_a_new_category
      revise_the_category
      delete_the_category
    end

    def create_a_new_category
      click_link 'manage_categories'
      click_link 'new_category'
      fill_in 'title', :with => 'the category'
      click_button 'commit'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/categories)
    end

    def revise_the_category
      click_link 'the category'
      fill_in 'title', :with => 'the ubercategory'
      click_button 'commit'
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/categories/\d+/edit)
    end

    def delete_the_category
      category = Category.find_by_title('the ubercategory')
      click_link "delete_category_#{category.id}"
      request.url.should =~ %r(/admin/sites/\d+/sections/\d+/categories)
    end
  end
end