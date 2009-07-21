require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class RbacUserTest < ActiveSupport::TestCase
  def setup
    super
    @user = User.find_by_first_name('a user')
    @role_attributes = [
      { "name" => "superuser", "selected" => "1" },
      { "name" => "admin", "context_id" => Site.first.id, "context_type" => "Site", "selected" => "1" }
    ]
  end

  # the roles association
  # FIXME implement ...

  # stub_scenario :user_having_several_roles
  # test 'roles.by_site returns all superuser, site and section roles for the given user' do
  #   roles = @user.roles.by_site(@site)
  #   roles.map(&:type).should == ['Rbac::Role::Superuser', 'Rbac::Role::Admin', 'Rbac::Role::Moderator']
  # end
  # 
  # test 'roles.by_context returns all roles by_site for the given object' do
  #   roles = @user.roles.by_context(@site)
  #   roles.map(&:type).should == ['Rbac::Role::Superuser', 'Rbac::Role::Admin', 'Rbac::Role::Moderator']
  # end
  # 
  # test 'roles.by_context adds the implicit roles for the given object if it has any' do
  #   @topic.stub!(:implicit_roles).and_return [@comment_author_role]
  #   roles = @user.roles.by_context(@topic)
  #   roles.map(&:type).should == ['Rbac::Role::Superuser', 'Rbac::Role::Admin', 'Rbac::Role::Moderator', 'Rbac::Role::Author']
  # end
  # 
  
  test 'makes the new user a superuser' do
    user = User.create_superuser(@valid_user_params)
    user.has_role?(:superuser).should be_true
  end

  test "User.by_role_and_context finds all superusers" do
    users = User.by_role_and_context(:superuser, nil)
    users.size.should == 1
  end

  test "User.by_role_and_context finds all admins of a given site" do
    site = Site.find_by_name('site with blog')
    users = User.by_role_and_context(:admin, site)
    users.size.should == 1
  end

  test "role_matches_attributes?" do
    role = Role.new(:name => 'superuser')
  
    attributes = { :name => 'superuser' }
    assert_equal true, User.role_matches_attributes?(attributes, role)
  
    attributes = { :name => 'god' }
    assert_equal false, User.role_matches_attributes?(attributes, role)
  
    role = Role.new(:name => 'admin', :context_type => 'Site', :context_id => '1')
    attributes = { :name => 'admin', :context_type => 'Site', :context_id => '1' }
    assert_equal true, User.role_matches_attributes?(attributes, role)
  
    attributes = { :name => 'admin', :context_type => 'Site', :context_id => '2' }
    assert_equal false, User.role_matches_attributes?(attributes, role)
  end
  
  test "selected roles" do
    fields = ['name', 'context_type', 'context_id']
    expected = [Role.new(@role_attributes[0].slice(*fields)), Role.new(@role_attributes[1].slice(*fields))]
    assert_equal expected.map { |r| r.attributes.slice(*fields) }, @user.selected_roles(@role_attributes).map { |r| r.attributes.slice(*fields) }
  
    @user.roles.build(@role_attributes[0].slice(*fields))
    expected = [Role.new(@role_attributes[1].slice(*fields))]
    assert_equal expected.map { |r| r.attributes.slice(*fields) }, @user.selected_roles(@role_attributes).map { |r| r.attributes.slice(*fields) }
  end

  test "unselected_roles" do
    fields = ['name', 'context_type', 'context_id']
    @role_attributes[0]['selected'] = '0'
    @user.roles.build(@role_attributes[0].slice(*fields))
    expected = [Role.new(@role_attributes[0].slice(*fields))]
    assert_equal expected.map { |r| r.attributes.slice(*fields) }, @user.unselected_roles(@role_attributes).map { |r| r.attributes.slice(*fields) }
  end
  
  test "creates new roles from the given attributes" do
    @user.roles.should be_empty
  
    @user.roles_attributes = @role_attributes
    @user.roles(true).size.should == 2
  end
  
  test "ignores parameters that do not have the :selected flag set" do
    @user.roles.should be_empty
  
    @role_attributes[0]['selected'] = '0'
    @user.roles_attributes = @role_attributes
  
    @user.roles(true).size.should == 1
  end
end