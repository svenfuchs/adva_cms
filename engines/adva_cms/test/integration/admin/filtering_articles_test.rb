require File.expand_path(File.dirname(__FILE__) + '/../../test_helper' )

module IntegrationTests
  class AdminFilteringArticlesTest < ActionController::IntegrationTest
    def setup
      super
      @section = Page.find_by_title 'a page'
      @site = @section.site
      use_site! @site
    end
    
    test "Admin filters articles list with unpublished flag" do
      login_as_admin
      visit_admin_articles_index_page
      filter_articles_with_state_unpublished
    end
    
    def visit_admin_articles_index_page
      visit "/admin/sites/#{@site.id}/sections/#{@section.id}/articles"
    end
    
    def filter_articles_with_state_unpublished
      select 'state', :from => "selected_filter_0"
      check  'filter_state_unpublished_0'
      click_button 'Apply'
      
      assert_select 'td[class=article]' do
        assert_select 'a[class=pending]', 'an unpublished page article'
      end
    end
  end
end