class MembersControllerTest < ActionController::TestCase
  before do
    host :site
    login_as :support
  end

  describe_requests do
    before :all do
      transaction do
        @invitation = Invitation.make
        @helper     = User.make
        @site       = @invitation.site
        @support    = @site.owner
        @user       = User.make
        Membership.make :user => @support, :site => @site
        Membership.make :user => @helper,  :site => @site
      end
    end

    describe "GET :index" do
      act! { get :index }

      before do
        @members = [@support, @helper]
      end

      it_assigns :members, :invitation => :not_nil
      it_renders :template, :index
    end

    describe "GET :invite" do
      act! { get :invite, :code => @invitation.code }

      before do
        login_as :user
      end

      it_assigns :invitation, :flash => {:notice => nil, :error => nil}
      it_renders :template, :invite
    end

    describe "GET :invite with site member" do
      act! { get :invite, :code => @invitation.code }

      it_assigns :invitation => nil, :flash => {:notice => :not_nil, :error => nil}
      it_redirects_to { dashboard_path }
    end

    describe "GET :invite with invalid code" do
      act! { get :invite }

      before do
        login_as :user
      end

      it_assigns :invitation => nil, :flash => {:notice => nil, :error => :not_nil}
      it_redirects_to { root_path }
    end

    describe "POST :create" do
      act! { post :create, :invitation => {:email => 'shamu@whale.com'} }

      it_assigns :invitation => :not_nil, :flash => {:notice => :not_nil}
      it_redirects_to { admin_members_path }
    end

    describe "POST :create (invalid)" do
      act! { post :create }

      it_assigns :invitation => :not_nil, :flash => {:notice => nil}
      it_renders :template, :new
    end
  end