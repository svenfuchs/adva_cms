require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper' ))

module IntegrationTests
  class UserDeletionTest < ActionController::IntegrationTest
    def setup
      super
      @site = use_site! 'site with pages'
    end
    
    test "A user deletes his account" do
      # user logs in to the site
      user = login_as_user
      
      # TODO
      # there's no user profile page so far
      # visit user_path
      # click_link 'Edit'
      # click_link 'Delete'

      # user deletes the own profile
      delete user_path

      # user should not be there anymore
      lambda { User.find(user.id) }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end
end