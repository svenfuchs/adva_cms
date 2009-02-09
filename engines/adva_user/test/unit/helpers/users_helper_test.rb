require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

class UsersHelperTest < ActionView::TestCase
  include UsersHelper

  def setup
    super
    
    @user = User.first
    @email = 'email@gravatar.com'
    @md5 = 'eafcd5f6d59e86088dfcf706831b297e'

    stub(self).request.returns(ActionController::TestRequest.new)
  end

  # who
  test "#who returns 'You' if the given user is the current user" do
    stub(self).current_user.returns(@user)
    who(@user).should == 'You'
  end

  test "#who returns the given user's name if the given user is not the current user" do
    stub(self).current_user.returns(nil)
    who(@user).should == @user.name
  end

  test "#gravatar_img returns an image tag with the class 'avatar' merged to the given options" do
    gravatar_img(@user).should have_tag('img[src^=?][class=?]', 'http://www.gravatar.com', 'avatar')
  end

  test "#gravatar_img adds the gravatar_url for the given user's email adress" do
    mock(self).gravatar_url(@user.email).returns('gravatar_url')
    gravatar_img(@user)
  end

  # gravatar_url
  test "#gravatar_url returns a default image url if the given email adress is blank" do
    gravatar_url.should == '/images/adva_cms/avatar.gif'
  end

  test "#gravatar_url the resulting gravatar url includes the md5/hexdigested email adress as the gravatar_id" do
    gravatar_url(@email).should =~ /gravatar_id=#{@md5}/
  end

  test "#gravatar_url the resulting gravatar url includes a size parameter with the given size" do
    gravatar_url(@email, 50).should =~ /size=50/
  end

  test "#gravatar_url the resulting gravatar url includes a default parameter" do
    gravatar_url(@email).should =~ %r(default=http://test.host/images/adva_cms/avatar.gif)
  end
end
