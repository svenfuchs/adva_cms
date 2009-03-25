require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class UserControllerTest < ActionController::TestCase
  with_common :a_site, :a_user

  view :form do
    has_tag 'input[name=?]', 'user[first_name]'
    has_tag 'input[name=?]', 'user[last_name]'
    has_tag 'input[name=?]', 'user[homepage]'
    has_tag 'input[name=?]', 'user[email]'
    has_tag 'input[name=?]', 'user[password]'
  end

  test "is an BaseController" do
    @controller.should be_kind_of(BaseController)
  end

  describe "GET to :new" do
    action { get :new }
    
    it_assigns :site
    it_renders :template, :new do
      has_form_posting_to user_path do
        shows :form
      end
    end
  end

  describe "POST to :create" do
    action { post :create, @params }
    it_assigns :user => :not_nil

    with :valid_user_params do
      it_saves :user
      it_triggers_event :user_registered
      it_triggers_event :user_created
      
      it_renders :template, :verification_sent do
        has_text 'sucessfully registered'
      end
      
      it "makes the new user a member of the current site" do
        @site.users.should include(assigns(:user))
      end
      
      expect "sends a validation email to the user" do
        # FIXME can't get this to behave ...
        # mock(UserMailer).deliver_signup_verification_email(anything, anything)
      end
    end

    with :invalid_user_params do
      it_does_not_save :user
      it_renders :template, :new
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end
  
  describe "GET to :verify" do
    action { get :verify }

    with "the user has been logged in from params[:token]" do
      before { stub(@controller).current_user.returns(@user) }

      with "the user can be verified" do
        before { @user.update_attributes!(:verified_at => nil) }
    
        it_triggers_event :user_verified
        it_assigns_flash_cookie :notice => :not_nil
        it_redirects_to Registry.get(:redirect, :verify)
      end

      with "the user can not be verified" do
        before { @user.update_attributes!(:verified_at => Time.now) }
    
        it_does_not_trigger_any_event
        it_assigns_flash_cookie :error => :not_nil
        it_redirects_to Registry.get(:redirect, :verify)
      end
    end
  end

  describe "DELETE to :destroy" do
    action { delete :destroy }
    it_guards_permissions :destroy, :user

    with :access_granted do
      before { stub(@controller).current_user.returns(@user) }
      
      it_destroys :user
      it_redirects_to { '/' }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :user_deleted
    end
  end
end