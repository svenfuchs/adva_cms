require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class UserRbacTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
      @superuser = User.find_by_email('a-superuser@example.com')
    end
    
    test "Updating the user account does not remove users roles" do
      login_as_superuser
      visit_user_edit_form
      fill_and_submit_user_edit_form
    end
    
    def visit_user_edit_form
      visit "admin/sites/#{@site.id}/users/#{@superuser.id}/edit"
      assert 'admin/users/edit'
    end
    
    def fill_and_submit_user_edit_form
      assert @superuser.has_role?(:superuser)
      
      fill_in 'user_first_name', :with => "the awesome"
      fill_in 'user_last_name', :with => "superuser"
      click_button 'Save'
      
      @superuser.reload
      assert @superuser.name == "the awesome superuser"
      assert @superuser.has_role?(:superuser)
    end
  end
end