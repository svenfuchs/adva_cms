require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# TODO
# try stubbing #perform_action for it_guards_permissions
# specify update_all action
# somehow publish passed/failed expectations from RR to test/unit result?
# make --with=access_control,caching options accessible from the console (Test::Unit runner)

# With.aspects << :access_control

class AdminSitesControllerTest < ActionController::TestCase
  tests Admin::SitesController

  # FIXME test in single_site_mode, too
  with_common :multi_sites_enabled, :a_site

  def default_params
    { :site_id => @site.id, :section_id => @page.id }
  end

  test "is an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :controller => 'admin/sites' do |r|
      r.it_maps :get,    "/admin/sites",        :action => 'index'
      r.it_maps :get,    "/admin/sites/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "/admin/sites/new",    :action => 'new'
      r.it_maps :post,   "/admin/sites",        :action => 'create'
      r.it_maps :get,    "/admin/sites/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "/admin/sites/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "/admin/sites/1",      :action => 'destroy', :id => '1'
    end
  end

  describe "GET to :index" do
    with :is_superuser do
      action { get :index }

      # FIXME
      # hard to test because :admin and :moderator roles need a context and
      # BaseController#require_authentication tests for has_role?(:admin)
      # it_guards_permissions :show, :site

      with :access_granted do
        it_assigns :sites
        it_renders :template, :index do
          has_tag 'table[id=sites] tbody tr', :count => Site.count do
            has_tag 'a[href=?]', admin_site_path(@site), @site.name
            has_tag 'a[href=?][class=?]', admin_site_path(@site), 'delete site', /delete/i
            has_tag 'a[href=?][class=?]', edit_admin_site_path(@site), 'edit site', /settings/i
            has_tag 'a[href=?][class=?]', "http://#{@site.host}", 'show site'
          end
        end
      end
    end
  end

  describe "GET to :show" do
    with :is_superuser do
      action { get :show, :id => @site.id }

      it_guards_permissions :show, :site

      with :access_granted do
        it_assigns :site
        it_renders :template, :show do
          # FIXME
          # :partial => 'admin/activities/activities'
          # :partial => 'recent_users'
          # :partial => 'unapproved_comments'
        end
      end
    end
  end

  describe "GET to :show 'require_authentication' does not succeed for a user without global role on site" do
    action { get :show, :id => @site.id }

    it_guards_permissions :show, :site

    with :is_moderator do
      it_assigns :site
      it_redirects_to { login_url(:return_to => admin_site_url(@site)) }
    end
  end

  describe "GET to :show 'require_authentication' does succeed for a user with global role on site" do
    action { get :show, :id => @site.id }

    it_guards_permissions :show, :site

    with :is_admin do
      it_assigns :site
      it_renders :template, :show
    end
  end

  describe "GET to :show for a site 'require_authentication' succeeds for a superuser" do
    action { get :show, :id => @site.id }

    it_guards_permissions :show, :site

    with :is_superuser do
      it_assigns :site
      it_renders :template, :show
    end
  end

  describe "GET to :index 'require_authentication' succeeds for a superuser" do
    action { get :index }

    it_guards_permissions :show, :site

    with :is_superuser do
      it_renders :template, :index
    end
  end

  describe "GET to :index 'require_authentication' does not succeed for a not logged in user" do
    action { get :show, :id => @site.id }

    it_guards_permissions :show, :site

    it_assigns :site
    it_redirects_to { login_url(:return_to => admin_site_url(@site)) }
  end

  describe "GET to :new" do
    with :is_superuser do
      action { get :new }

      # FIXME
      # hard to test because :admin and :moderator roles need a context and
      # BaseController#require_authentication tests for has_role?(:admin)
      # it_guards_permissions :create, :site

      with :access_granted do
        it_renders :template, :new do
          has_form_posting_to admin_sites_path do
            has_tag 'input[name=?]', 'section[title]'
            has_tag 'select[name=?]', 'section[type]'
          end
        end
      end
    end
  end

  describe "POST to :create" do
    with :is_superuser do
      action { post :create, @params }

      with :valid_site_params do
        # FIXME
        # hard to test because :admin and :moderator roles need a context and
        # BaseController#require_authentication tests for has_role?(:admin)
        # it_guards_permissions :create, :site

        with :access_granted do
          it_changes 'Site.count' => 1
          it_redirects_to { admin_site_url(Site.last) } # urgs
          it_assigns_flash_cookie :notice => :not_nil
        end
      end

      with :invalid_site_params do
        it_renders :template, :new
        it_assigns_flash_cookie :error => :not_nil
      end
    end
  end

  describe "GET to :edit" do
    with :is_superuser do
      action { get :edit, :id => @site.id }

      it_guards_permissions :update, :site

      with :access_granted do
        it_assigns :site
        it_renders :template, :edit do
          has_form_putting_to admin_site_path(@site) do
            # FIXME
            # SpamEngine::Filter.names.each do |name|
            #   next if name == 'Default'
            #   response.should have_tag('input[type=?][name=?][value=?]', 'checkbox', 'site[spam_options][filters][]', name)
            # end
            # SpamEngine::Filter.names.each do |name|
            #   template.should_receive(:render).with hash_including(:partial => "spam/#{name.downcase}_settings")
            # end
          end
        end
      end
    end
  end

  describe "PUT to :update" do
    with :is_superuser do
      action { put :update, @params.merge(:id => @site.id) }

      with :valid_site_params do
        before { @params[:site][:name] = 'name changed' }

        it_guards_permissions :update, :site

        with :access_granted do
          it_assigns :site
          it_updates :site
          it_redirects_to { edit_admin_site_url(@site) }
          it_assigns_flash_cookie :notice => :not_nil

          it "updates the site with the site params" do
            @site.reload.name.should =~ /changed/
          end
        end
      end

      with :invalid_site_params do
        it_renders :template, :edit
        it_assigns_flash_cookie :error => :not_nil
      end
    end
  end

  describe "DELETE to :destroy" do
    with :is_superuser do
      action { delete :destroy, :id => @site.id }

      it_guards_permissions :destroy, :site

      with :access_granted do
        it_assigns :site
        it_destroys :site
        it_redirects_to { admin_sites_url }
        it_assigns_flash_cookie :notice => :not_nil
      end
    end
  end
end
