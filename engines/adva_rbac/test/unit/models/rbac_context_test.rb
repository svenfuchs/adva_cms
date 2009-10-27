require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class RbacContextTest < ActiveSupport::TestCase
  def setup
    super
    @account = Account.find_by_name('an account')
    @site    = Site.find_by_name('site with pages')
  end
  
  define_method "test: roles have a reference to an ancestor context" do
    superuser = Rbac::Role.find_by_name('superuser')
    admin     = Rbac::Role.find_by_name('admin')
    @moderator = User.find_by_first_name('a moderator')
    moderator = Rbac::Role.find_by_user_id(@moderator.id)

    assert_equal nil,   superuser.ancestor_context
    assert_equal nil,   admin.ancestor_context
    assert_equal @site, moderator.ancestor_context
  end
  
  define_method "test: an account has members" do
    assert @account.members.empty?
    assert !@site.members.empty?
  end
  
  # define_method "test: any user is a user of an account and a site" do
  #   user = User.find_by_name('a user')
  # 
  #   assert @site.users.include?(user)
  #   assert @account.users.include?(user)
  # end
  # 
  # define_method "test: an account has members" do
  #   @account.resources << @site
  #   assert !@account.members.empty?
  # end
end