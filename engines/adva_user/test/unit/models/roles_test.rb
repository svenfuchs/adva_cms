require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class RolesTest < ActiveSupport::TestCase
  def setup
    super

    @superuser = User.find_by_first_name('a superuser')
    @admin     = User.find_by_first_name('an admin')
    @moderator = User.find_by_first_name('a moderator')
    @user      = User.first
    @anonymous = User.anonymous

    @section   = @moderator.roles.detect { |r| r.context.is_a?(Section) }.context
    @site      = @section.site
    @content   = @section.articles.first
    @author    = @content.author

    @another_site = Site.find_by_name 'another site'
  end

  # has_role? (with a user)
  test "a user has the role :user" do
    @user.should have_role(:user)
  end

  # TODO Has not. Error in spec definition or unexpected behaviour?
  # test "a user has the role :author for another user's content" do
  #  @user.has_role?(:author, @content).should be_true
  #end

  test "a user does not have the role :moderator" do
    @user.should_not have_role(:moderator, :context => @section)
  end

  test "a user does not have the role :admin" do
    @user.should_not have_role(:admin, :context => @site)
  end

  test "a user does not have the role :superuser" do
    @user.should_not have_role(:superuser)
  end

  # has_role? (with a content author)
  test "a content author has the role :user" do
    @author.should have_role(:user)
  end

  test 'a content author has the role :author for that content' do
    @author.should have_role(:author, :context => @content)
  end

  test "a content author does not have the role :moderator" do
    @author.should_not have_role(:moderator, :context => @section)
  end

  test "a content author does not have the role :admin" do
    @author.should_not have_role(:admin, :context => @site)
  end

  test "a content author does not have the role :superuser" do
    @author.should_not have_role(:superuser)
  end

  # has_role? (with a section moderator)
  test "a section moderator has the role :user" do
    @moderator.should have_role(:user)
  end

  test "a section moderator has the role :author for another user's content" do
    @moderator.should have_role(:author, :context => @content)
  end

  test "a section moderator has the role :moderator for that section" do
    @moderator.should have_role(:moderator, :context => @section)
  end

  test "a section moderator does not have the role :admin" do
    @moderator.should_not have_role(:admin, :context => @site)
  end

  test "a section moderator does not have the role :superuser" do
    @moderator.should_not have_role(:superuser)
  end

  # has_role? (with a site admin)
  test "a site admin has the role :user" do
    @admin.should have_role(:user)
  end

  test "a site admin has the role :author for another user's content" do
    @admin.should have_role(:author, :context => @content)
  end

  test "a site admin has the role :moderator for sections belonging to that site" do
    @admin.should have_role(:moderator, :context => @section)
  end

  test "a site admin has the role :admin for that site" do
    @admin.should have_role(:admin, :context => @site)
  end

  test "a site admin does not have role :admin for another site" do
    @admin.should_not have_role(:admin, :context => @another_site)
  end

  test "a site admin does not have role :admin for a non-existent site" do
    lambda { @admin.has_role?(:admin, nil) }.should raise_error
  end

  test "a site admin does not have the role :superuser" do
    @admin.should_not have_role(:superuser)
  end

  # has_role? (with a superuser)
  test "a superuser has the role :user" do
    @superuser.should have_role(:user)
  end

  test "a superuser has the role :author for another user's content" do
    @superuser.should have_role(:author, :context => @content)
  end

  test "a superuser has the role :moderator for sections belonging to that site" do
    @superuser.should have_role(:moderator, :context => @section)
  end

  test "a superuser has the role :site for that site" do
    @superuser.should have_role(:admin, :context => @site)
  end

  test "a superuser has the role :superuser" do
    @superuser.should have_role(:superuser)
  end
end
