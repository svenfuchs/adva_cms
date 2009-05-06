require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class MembershipsTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
    end

    test "when superuser creates a new user on the backend,
          the new user should have a membership to the page it was created on (fix for bug #288)" do
      login_as_superuser
      visit_new_user_form
      post_the_new_user_form
    end
    
    def visit_new_user_form
      visit "/admin/sites/#{@site.id}/users/new"
      renders_template "admin/users/new"
    end
    
    def post_the_new_user_form
      fill_in :user_first_name, :with => 'John'
      fill_in :user_last_name,  :with => 'Doe'
      fill_in :user_email,      :with => 'memberships@test.org'
      fill_in :user_password,   :with => 'pass'
      click_button :save
      
      user = User.find_by_email('memberships@test.org')
      assert !user.memberships.blank?
    end
  end
end