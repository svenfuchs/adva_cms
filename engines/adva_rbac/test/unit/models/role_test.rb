require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class RoleTest < ActiveSupport::TestCase
  def setup
    super

    @superuser = User.find_by_first_name('a superuser')
    @admin     = User.find_by_first_name('an admin')
    @moderator = User.find_by_first_name('a moderator')
    @user      = User.find_by_first_name('a user')
    @anonymous = User.anonymous

    @section   = @moderator.roles.detect { |r| r.context.is_a?(Section) }.context
    @site      = @section.site
    @content   = @section.articles.first
    @author    = @content.author

    @another_site = Site.find_by_name 'another site'
  end

  # has_role? (with a user)
  test "a user has the role :user" do
    @user.has_role?(:user).should be_true
  end
  
  test "a user does not have the role :moderator" do
    @user.has_role?(:moderator, @section).should be_false
  end
  
  test "a user does not have the role :admin" do
    @user.has_role?(:admin, @site).should be_false
  end
  
  test "a user does not have the role :superuser" do
    @user.has_role?(:superuser).should be_false
  end
  
  # has_role? (with a content author)
  test "a content author has the role :user" do
    @author.has_role?(:user).should be_true
  end
  
  test 'a content author has the role :author for that content' do
    @author.has_role?(:author, @content).should be_true
  end
  
  test "a content author does not have the role :moderator" do
    @author.has_role?(:moderator, @section).should be_false
  end
  
  test "a content author does not have the role :admin" do
    @author.has_role?(:admin, @site).should be_false
  end
  
  test "a content author does not have the role :superuser" do
    @author.has_role?(:superuser).should be_false
  end
  
  # has_role? (with a section moderator)
  test "a section moderator has the role :user" do
    @moderator.has_role?(:user).should be_true
  end
  
  test "a section moderator has the role :author for another user's content" do
    @moderator.has_role?(:author, @content).should be_true
  end
  
  test "a section moderator has the role :moderator for that section" do
    @moderator.has_role?(:moderator, @section).should be_true
  end
  
  test "a section moderator does not have the role :admin" do
    @moderator.has_role?(:admin, @site).should be_false
  end
  
  test "a section moderator does not have the role :superuser" do
    @moderator.has_role?(:superuser).should be_false
  end
  
  # has_role? (with a site admin)
  test "a site admin has the role :user" do
    @admin.has_role?(:user).should be_true
  end
  
  test "a site admin has the role :author for another user's content" do
    @admin.has_role?(:author, @content).should be_true
  end
  
  test "a site admin has the role :moderator for sections belonging to that site" do
    @admin.has_role?(:moderator, @section).should be_true
  end
  
  test "a site admin has the role :admin for that site" do
    @admin.has_role?(:admin, @site).should be_true
  end
  
  test "a site admin does not have role :admin for another site" do
    @admin.has_role?(:admin, @another_site).should be_false
  end
  
  test "a site admin does not have role :admin for a non-existent site" do
    @admin.has_role?(:admin, nil).should be_false
  end
  
  test "a site admin does not have the role :superuser" do
    @admin.has_role?(:superuser).should be_false
  end
  
  # has_role? (with a superuser)
  test "a superuser has the role :user" do
    @superuser.has_role?(:user).should be_true
  end
  
  test "a superuser has the role :author for another user's content" do
    @superuser.has_role?(:author, @content).should be_true
  end
  
  test "a superuser has the role :moderator for sections belonging to that site" do
    @superuser.has_role?(:moderator, @section).should be_true
  end
  
  test "a superuser has the role :site for that site" do
    @superuser.has_role?(:admin, @site).should be_true
  end
  
  test "a superuser has the role :superuser" do
    @superuser.has_role?(:superuser).should be_true
  end
end