require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class PasswordControllerTest < ActionController::TestCase
  with_common :a_site, :a_user

  test "is an BaseController" do
    @controller.should be_kind_of(BaseController)
  end

  describe "GET to :new" do
    action { get :new }
    
    it_assigns :site
    it_renders :template, :new do
      has_form_posting_to password_path do
        has_tag 'input[name=?]', 'user[email]'
      end
    end
  end

  describe "POST to :create" do
    action { post :create, @params }
    
    with "an email adress that belongs to a user" do
      before { @params = { :user => { :email => @user.email } } } 
      
      it_triggers_event :user_password_reset_requested
      it_assigns_flash_cookie :notice => :not_nil
      it_redirects_to { edit_password_url }
    end
    
    with "an email adress that does not belong to a user" do
      before { @params = { :user => { :email => 'none' } } } 

      it_does_not_trigger_any_event
      it_assigns_flash_cookie :notice => :not_nil # feature, not a bug!
      it_renders_template :new
    end
  end
  
  describe "GET to :edit" do
    action { get :edit, @params }
    
    with "the user is logged in (via cookie or token)" do
      before do
        stub(@controller).current_user.returns(@user)
      end

      it_renders_template :edit do
        has_tag 'input[name=?][type=password]', 'user[password]'
      end
    end

    with "the user is not logged in (missing or invalid token)" do
      it_renders_template :edit do
        has_tag 'input[name=?][type=text]', 'token'
        has_tag 'input[name=?][type=password]', 'user[password]'
      end
    end
  end
  
  describe "PUT to :update" do
    action { put :update, @params }
    
    with "the user is logged in" do
      before { stub(@controller).current_user.returns(@user) }
      
      with "valid password parameters" do
        before { @params = { :user => { :password => 'new password' } } } 

        it_triggers_event :user_password_updated
        it_assigns_flash_cookie :notice => :not_nil
        it_redirects_to { root_url }
      end
    
      describe "given an invalid email address" do
        before { @params = { :user => { :password => nil } } } 
      
        it_does_not_trigger_any_event
        it_assigns_flash_cookie :error => :not_nil
        it_renders_template :edit
      end
    end

    with "the user is not logged in" do
      before { stub(@controller).current_user.returns(nil) }

      it_does_not_trigger_any_event
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template :edit do
        has_tag 'input[name=?][type=?]', 'token', 'text'
        has_tag 'input[name=?][type=?]', 'user[password]', 'password'
      end
    end
  end
end
