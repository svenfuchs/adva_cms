require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class EditUserTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
    end
    
    test "setting all global roles for a user with no global role on site, yet" do
      login_as_superuser
      visit_edit_user_form
      
      assert_select "input[name=?][checked=?]", "user[roles_attributes][0][selected]", "checked", :count => 0
      assert_select "input[name=?][checked=?]", "user[roles_attributes][1][selected]", "checked", :count => 0
      assert_select "input[name=?][checked=?]", "user[roles_attributes][2][selected]", "checked", :count => 0
      assert_select "input[name=?][checked=?]", "user[roles_attributes][3][selected]", "checked", :count => 0
      assert_select "input[name=?][checked=?]", "user[roles_attributes][4][selected]", "checked", :count => 0      
      
      check 'user[roles_attributes][0][selected]'
      check 'user[roles_attributes][1][selected]'
      check 'user[roles_attributes][2][selected]'
      check 'user[roles_attributes][3][selected]'
      check 'user[roles_attributes][4][selected]'
      
      click_button 'commit'
      
      visit_edit_user_form
      
      assert_select "input[name=?][checked=?]", "user[roles_attributes][0][selected]", "checked"
      assert_select "input[name=?][checked=?]", "user[roles_attributes][1][selected]", "checked"
      assert_select "input[name=?][checked=?]", "user[roles_attributes][2][selected]", "checked"
      assert_select "input[name=?][checked=?]", "user[roles_attributes][3][selected]", "checked"
      assert_select "input[name=?][checked=?]", "user[roles_attributes][4][selected]", "checked"                  
    end
    
    def visit_edit_user_form
      moderator = User.find_by_first_name('a moderator')
      visit "/admin/sites/#{@site.id}/users/#{moderator.id}/edit"
      renders_template "admin/users/edit"
    end
    
  end
end