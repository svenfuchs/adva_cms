require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class AnonymousTest < ActiveSupport::TestCase
  def setup
    super
    @anonymous = User.anonymous :name => 'John Doe'
  end

  test 'acts as authenticated user (with single token authentication)' do
    # FIXME implement matcher
    # User.should act_as_authenticated_user
  end

  # VALIDATIONS
  
  test 'validates the presence of a name' do
    @anonymous.should validate_presence_of(:first_name)
  end

  test 'validates the presence of an email' do
    @anonymous.should validate_presence_of(:email)
  end

  test 'validates the length of the name (3-40 chars)' do
    # FIXME implement matcher
    # @anonymous.should validate_length_of(:first_name, :within => 3..40)
  end

  test 'email format validation succeeds with a valid email address' do
    @anonymous.email = 'valid@email.org'
    @anonymous.should be_valid
  end

  test 'email format validation fails with an invalid email address' do
    @anonymous.email = 'invalid-email.org'
    @anonymous.should_not be_valid
  end
  
  # INSTANCE METHODS

  test '#has_role? returns true when the passed role is Role::Anonymous' do
    @anonymous.has_role?(:anonymous).should be_true
  end

  test '#has_role? returns false when the passed role is not Role::Anonymous' do
    @anonymous.has_role?(:user).should be_false
  end

  test '#anonymous? returns true' do
    @anonymous.anonymous?.should be_true
  end

  test '#registered? returns false' do
    @anonymous.registered?.should be_false
  end
end
