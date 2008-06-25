require File.dirname(__FILE__) + '/../spec_helper'

describe UsersHelper do
  describe '#authorize_elements' do
    it "returns a javascript tag that executes /user/[uid]/roles.js"
  end
  
  describe "#authorized_link_to" do
    before :each do
      helper.stub!(:add_authorizing_css_classes!)
      helper.stub!(:link_to)
    end
    
    it "adds authorizing css classes to the :class option" do
      helper.should_receive(:add_authorizing_css_classes!)
      helper.authorized_link_to('text', 'url', :update, Object.new)
    end
    
    it "delegates to link_to" do
      helper.should_receive(:link_to).with 'text', 'url', {}
      helper.authorized_link_to('text', 'url', :update, Object.new)
    end
  end
  
  describe '#add_authorizing_css_classes' do
    it "adds css classes that allow a user to see an element to the given options"
  end
  
  describe '#authorizing_css_classes' do
    before :each do
      @role = Role.build :superuser
    end

    it "turns the given roles to css classes that allow a user to see an element" do
      helper.authorizing_css_classes([@role]).should == 'superuser'
    end

    it "given the option :quote it encloses the classes in single quotes" do
      helper.authorizing_css_classes([@role], {:quote => true}).should == "'superuser'"
    end

    it "given the option :separator it joins the classes using it" do
      helper.authorizing_css_classes([@role, @role], {:separator => ','}).should == "superuser,superuser"
    end
  end
  
  describe '#who' do
    before :each do
      @user = User.new :name => 'name'
      helper.stub!(:current_user)
    end
    
    it "returns 'You' if the given user is the current user" do
      helper.stub!(:current_user).and_return @user
      helper.who(@user).should == 'You'
    end
    
    it "returns the given user's name if the given user is not the current user" do
      helper.who(@user).should == 'name'
    end
  end
  
  describe '#gravatar_img' do
    before :each do
      @user = User.new :email => 'email@gravatar.com'
      helper.stub!(:gravatar_url).and_return('gravatar_url')
    end
    
    it "returns an image tag with the class 'avatar' merged to the given options" do
      helper.gravatar_img(@user).should have_tag('img[src=?][class=?]', '/images/gravatar_url', 'avatar')
    end
    
    it "adds the gravatar_url for the given user's email adress" do
      helper.should_receive(:gravatar_url).with('email@gravatar.com').and_return('gravatar_url')
      helper.gravatar_img(@user)
    end
  end
  
  describe '#gravatar_url' do
    before :each do
      @email = 'email@gravatar.com'
      md5 = 'eafcd5f6d59e86088dfcf706831b297e'
      helper.stub!(:request).and_return ActionController::TestRequest.new
    end
    
    it "returns a default image url if the given email adress is blank" do
      helper.gravatar_url.should == 'avatar.gif'
    end
    
    it "the resulting gravatar url includes a gravatar_id parameter with the given email adress turned into a md5 hexdigest" do
      helper.gravatar_url(@email).should =~ /gravatar_id=#{@md5}/
    end
    
    it "the resulting gravatar url includes a size parameter with the given size" do
      helper.gravatar_url(@email, 50).should =~ /size=50/
    end
    
    it "the resulting gravatar url includes a default parameter" do
      helper.gravatar_url(@email).should =~ %r(default=http://test.host/images/avatar.gif)
    end
  end
end