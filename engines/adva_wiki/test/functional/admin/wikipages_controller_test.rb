require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# With.aspects << :access_control

class AdminWikipagesControllerTest < ActionController::TestCase
  tests Admin::WikipagesController

  with_common :is_superuser, :a_site, :a_wiki, :a_wikipage

  def default_params
    { :site_id => @site.id, :section_id => @section.id }
  end

  view :form do
    has_tag 'input[name=?]', 'wikipage[title]'
    has_tag 'textarea[name=?]', 'wikipage[body]'
    has_tag 'select[name=?]', 'wikipage[author_id]'
    # FIXME displays checkboxes for categories
    # FIXME displays a selectbox for selecting an author for an article
  end

  test "is an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/sections/1/', :site_id => "1", :section_id => "1" do |r|
      r.it_maps :get,    "wikipages",        :action => 'index'
      r.it_maps :get,    "wikipages/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "wikipages/new",    :action => 'new'
      r.it_maps :post,   "wikipages",        :action => 'create'
      r.it_maps :get,    "wikipages/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "wikipages/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "wikipages/1",      :action => 'destroy', :id => '1'
    end
  end

  describe "GET to :index" do
    action { get :index, default_params }
    it_guards_permissions :show, :wikipage do
      it_assigns :wikipages
      it_renders :template, :index do
        has_tag 'table[id=wikipages]'
      end
    end
  end

  describe "GET to :new" do
    action { get :new, default_params }
    it_guards_permissions :create, :wikipage do
      it_assigns :site, :section, :wikipage => :not_nil
      it_renders :template, :new do
        shows :form
      end
    end
  end

  describe "POST to :create" do
    action { post :create, default_params.merge(@params || {}) }
    it_guards_permissions :create, :wikipage do
      it_assigns :wikipage => :not_nil

      with :valid_wikipage_params do
        it_saves :wikipage
        it_redirects_to { edit_admin_wikipage_url(@site, @section, assigns(:wikipage)) }
        it_assigns_flash_cookie :notice => :not_nil
        it_triggers_event :wikipage_created
      end

      with :invalid_wikipage_params do
        it_does_not_save :wikipage
        it_renders :template, :new
        it_assigns_flash_cookie :error => :not_nil
        it_does_not_trigger_any_event
      end
    end
  end

  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @wikipage.id) }
    it_guards_permissions :update, :wikipage do
      it_assigns :wikipage
      it_renders :template, :edit do
        shows :form
      end
    end
  end

  describe "PUT to :update" do
    action do
      Wikipage.with_observers :wikipage_sweeper do
        put :update, default_params.merge(:id => @wikipage.id).merge(@params || { :wikipage => {} })
      end
    end

    it_guards_permissions :update, :wikipage do
      with "no version param given" do
        with "valid wikipage params" do
          before {
            @params = { :wikipage => { :body => 'the updated wikipage body', :updated_at => "#{@wikipage.updated_at}" } }
          }

          it_updates :wikipage
          it_redirects_to { edit_admin_wikipage_url(@site, @section, @wikipage) }
          it_assigns_flash_cookie :notice => :not_nil
          it_triggers_event :wikipage_updated
          it_sweeps_page_cache :by_reference => :wikipage
        end

        with "invalid wikipage params" do
          before { @params = { :wikipage => { :title => '', :updated_at => "#{@wikipage.updated_at}" } } }

          it_does_not_update :wikipage
          it_renders :template, :edit
          it_assigns_flash_cookie :error => :not_nil
          it_does_not_trigger_any_event
          it_does_not_sweep_page_cache
        end
      end

      with "a version param given" do
        it_guards_permissions :update, :wikipage

        with :access_granted do
          with "the requested version exists (succeeds)" do
            before {
              @wikipage.update_attributes(:body => "#{@wikipage.body} was changed")
              @params = { :wikipage => { :version => '1', :updated_at => "#{@wikipage.updated_at}"  } }
            }

            it_rollsback :wikipage, :to => 1
            it_triggers_event :wikipage_rolledback
            it_assigns_flash_cookie :notice => :not_nil
            it_redirects_to { edit_admin_wikipage_url(@site, @section, @wikipage) }
            it_sweeps_page_cache :by_reference => :wikipage
          end

          with "the requested version does not exist (fails)" do
            before { @params = { :wikipage => { :version => '10', :updated_at => "#{@wikipage.updated_at}" } } }

            it_does_not_rollback :wikipage
            it_does_not_trigger_any_event
            it_assigns_flash_cookie :error => :not_nil
            it_redirects_to { edit_admin_wikipage_url(@site, @section, @wikipage) }
            it_does_not_sweep_page_cache
          end
        end
      end
    end
  end

  describe "PUT to :update" do
    with "incorrect time stamp" do
      action do
        Wikipage.with_observers :wikipage_sweeper do
          params = default_params.merge(@params || { :wikipage => {} }).merge(:id => @wikipage.id)
          params[:wikipage][:updated_at] = "#{Time.parse('2002-01-01 12:00:00')}"
          put :update, params
        end
      end
      # FIXME - test with optimistic locking failing, too
      with "no version param given" do
        with :valid_wikipage_params do
          it_guards_permissions :update, :wikipage
          it_assigns :site, :section, :wikipage
          it_assigns_flash_cookie :error => :not_nil
          it_does_not_trigger_any_event
          it_does_not_sweep_page_cache #:by_reference => :wikipage
        end
      end
    end
  end

  describe "PUT to :update" do
    action do
      Wikipage.with_observers :wikipage_sweeper do
        params = default_params.merge(@params || { :wikipage => {} }).merge(:id => @wikipage.id)
        params[:wikipage][:updated_at] = "#{@wikipage.updated_at}"
        put :update, params
      end
    end

    it_guards_permissions :update, :wikipage

    # FIXME - test with optimistic locking failing, too
    with "no version param given" do
      it_guards_permissions :update, :wikipage

      with :access_granted do
        with :valid_wikipage_params do
          it_updates :wikipage

          it_redirects_to { edit_admin_wikipage_url(@site, @section, @wikipage) }

          it_assigns_flash_cookie :notice => :not_nil
          it_triggers_event :wikipage_updated
          it_sweeps_page_cache :by_reference => :wikipage
        end
      end

      with :invalid_wikipage_params do
          it_does_not_update :wikipage
          it_renders :template, :edit
          it_assigns_flash_cookie :error => :not_nil
          it_does_not_trigger_any_event
          it_does_not_sweep_page_cache
      end
    end

    with "a version param given" do
      before { @params = { :wikipage => { :version => '1' } } }
      it_guards_permissions :update, :wikipage

      with :access_granted do
        with 'the wikipage has the requested revision (succeeds)' do
          it_rollsback :wikipage, :to => 1
          it_triggers_event :wikipage_rolledback
          it_assigns_flash_cookie :notice => :not_nil
          it_redirects_to { edit_admin_wikipage_url(@site, @section, @wikipage) }
          it_sweeps_page_cache :by_reference => :wikipage
        end

        with "the wikipage does not have the requested revision (fails)" do
          before { @params = { :wikipage => { :version => '10' } } }
            it_does_not_rollback :wikipage
            it_does_not_trigger_any_event
            it_assigns_flash_cookie :error => :not_nil
            it_redirects_to { edit_admin_wikipage_url(@site, @section, @wikipage) }
            it_does_not_sweep_page_cache
        end
      end
    end
  end

  describe "DELETE to :destroy" do
    action { delete :destroy, default_params.update(:id => @wikipage.id) }

    it_guards_permissions :destroy, :wikipage do
      it_redirects_to { admin_wikipages_path(@site, @section) }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :wikipage_deleted
      it_sweeps_page_cache :by_reference => :wikipage
    end
  end
end
