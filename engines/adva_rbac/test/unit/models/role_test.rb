require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class RoleTest < ActiveSupport::TestCase
  def setup
    super

    @superuser = User.find_by_first_name('a superuser')
    @admin     = User.find_by_first_name('an admin')
    @moderator = User.find_by_first_name('a moderator')
    @another_moderator = User.find_by_first_name('another moderator')
    @another_author = User.find_by_first_name('a author')
    @user      = User.find_by_first_name('a user')
    @anonymous = User.anonymous
    @designer  = User.find_by_first_name('a designer')

    @section   = @moderator.roles.detect { |r| r.context.is_a?(Section) }.context
    @site      = @section.site
    @content   = @section.articles.first
    @author    = @content.author

    @another_site = Site.find_by_name 'another site'
  end

  test "a superuser has the global role :superuser" do
    @superuser.has_global_role?(:superuser).should be_true
    @superuser.has_global_role?(:superuser, @site).should be_true
    @superuser.has_global_role?(:superuser, @another_site).should be_true
  end

  test "a admin for 'site' has the global role :admin on 'site'" do
    @admin.has_global_role?(:admin, @site).should be_true
  end

  test "a moderator for 'site' has the global role :moderator on 'site'" do
    @another_moderator.has_global_role?(:moderator, @site).should be_true
  end

  test "a author for 'site' has the global role :author on 'site'" do
    @another_author.has_global_role?(:author, @site).should be_true
  end

  test "a designer for 'site' has the global role :designer on 'site'" do
    @designer.has_global_role?(:designer, @site).should be_true
  end

  test "a admin for 'site' does not have the global role :admin on 'another site'" do
    @admin.has_global_role?(:admin, @another_site).should be_false
  end

  test "a moderator for a page of 'site' does not have the global role :moderator on 'site'" do
    @moderator.has_global_role?(:moderator, @site).should be_false
  end

  test "a superuser has permissions for the admin areas of all sites" do
    @superuser.has_permission_for_admin_area?(@site).should be_true
    @superuser.has_permission_for_admin_area?(@another_site).should be_true
  end

  test "a admin, moderator, author and designer for 'site' have permission for the admin area of 'site'" do
    @admin.has_permission_for_admin_area?(@site).should be_true
    @another_moderator.has_permission_for_admin_area?(@site).should be_true
    @another_author.has_permission_for_admin_area?(@site).should be_true
    @designer.has_permission_for_admin_area?(@site).should be_true
  end

  test "a admin, moderator, author and designer for 'site' do not have permissions for the admin area of 'another_site'" do
    @admin.has_permission_for_admin_area?(@another_site).should be_false
    @another_moderator.has_permission_for_admin_area?(@another_site).should be_false
    @author.has_permission_for_admin_area?(@another_site).should be_false
    @designer.has_permission_for_admin_area?(@another_site).should be_false
  end

  test "a moderator for a page of a 'site' does not have permission for the admin area of 'site'" do
    @moderator.has_permission_for_admin_area?(@site).should be_false
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
