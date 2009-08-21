require File.expand_path(File.dirname(__FILE__) + "/../../test_helper")

# With.aspects << :access_control

class AdminSectionsControllerTest < ActionController::TestCase
  tests Admin::SectionsController

  # FIXME caching specs fail in :a_blog context
  with_common :is_superuser, :a_page

  def default_params
    { :site_id => @site.id }
  end

  test "is an Admin::BaseController" do
    @controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |r|
      r.it_maps :get,    "sections",        :action => 'index'
      r.it_maps :get,    "sections/1",      :action => 'show',    :id => '1'
      r.it_maps :get,    "sections/new",    :action => 'new'
      r.it_maps :post,   "sections",        :action => 'create'
      r.it_maps :get,    "sections/1/edit", :action => 'edit',    :id => '1'
      r.it_maps :put,    "sections/1",      :action => 'update',  :id => '1'
      r.it_maps :delete, "sections/1",      :action => 'destroy', :id => '1'
    end
  end

  test "section url in :de locale" do
    site = Site.first
    section = Section.first
    assert_equal "/admin/sites/#{site.id}/sections/#{section.id}", admin_section_path(site, section)
    I18n.locale = :de
    assert_equal "/de/admin/sites/#{site.id}/sections/#{section.id}", admin_section_path(site, section)
    I18n.locale = :en
  end

  describe "GET to :index" do
    action { get :index, default_params }

    it_guards_permissions :show, :sections

    with :access_granted do
      it_assigns :site, :sections
      it_renders :template, :index do
        has_tag 'table[id=sections] tr td a[href=?]', edit_admin_section_path(@site, @section)
      end
    end
  end

  describe "GET to :new" do
    action { get :new, default_params }
    it_guards_permissions :create, :section

    with :access_granted do
      it_assigns :site, :section => :not_nil
      it_renders :template, :new do
        has_form_posting_to admin_sections_path do
          has_tag 'select[name=?]', 'section[type]'
          has_tag 'input[name=?]', 'section[title]'
        end
      end
    end
  end

  describe "POST to :create" do
    action do
      Section.with_observers :section_sweeper do
        post :create, default_params.merge(@params)
      end
    end

    with :valid_page_params do
      it_guards_permissions :create, :section

      with :access_granted do
        it_assigns :site, :section => :not_nil
        it_redirects_to { @controller.admin_section_contents_url(assigns(:section)) }
        it_assigns_flash_cookie :notice => :not_nil
        it_sweeps_page_cache :by_site => :site
        # FIXME implement: it_triggers_event :section_created

        it "associates the new Section to the current site" do
          assigns(:section).site.should == @site
        end
      end

      with :invalid_page_params do
        it_assigns :site, :section => :not_nil
        it_renders :template, :new
        it_assigns_flash_cookie :error => :not_nil
      end
    end
  end

  describe "GET to :edit" do
    action { get :edit, default_params.merge(:id => @section.id) }
    it_guards_permissions :update, :section

    with :access_granted do
      it_assigns :site, :section
      it_renders :template, :edit do
        has_form_putting_to admin_section_path do
          has_tag 'input[name=?]', 'section[title]'
          # FIXME
          # renders the admin/sections/settings/section partial if the section is a Section
          # renders the admin/sections/settings/blog partial if the section is a Blog
          # renders the admin/sections/settings/permissions partial
        end
      end
    end
  end

  describe "PUT to :update" do
    action do
      Section.with_observers :section_sweeper do
        params = default_params.merge(@params).merge(:id => @section.id)
        params[:section][:title] = "#{@section.title} was changed" if params[:section][:title].present?
        put :update, params
      end
    end

    with :valid_page_params do
      it_guards_permissions :update, :section

      with :access_granted do
        it_assigns :section
        it_updates :section
        it_redirects_to { edit_admin_section_url(@site, @section) }
        it_assigns_flash_cookie :notice => :not_nil
        # FIXME implement: it_triggers_event :section_updated
        it_sweeps_page_cache :by_section => :section
      end
    end

    with :invalid_page_params do
      with :access_granted do
        it_renders :template, :edit
        it_assigns_flash_cookie :error => :not_nil
      end
    end

    with "valid theme settings" do
      before { @params = { :section => { :template => 'the/template', :layout => 'the/layout' } } }
      with :access_granted do
        it_updates :section
        it "saves the template and layout to the section" do
          assigns(:section).template.should == 'the/template'
          assigns(:section).layout.should == 'the/layout'
        end
      end
    end
  end

  describe "PUT to :update_all" do
    action do
      params = {:sections => {@section.id => {'parent_id' => @another_section.id}}}
      put :update_all, default_params.merge(params)
    end

    before do
      @another_section = Section.find_by_permalink('another-page')
      @old_path = @section.path
    end

    it_guards_permissions :update, :section

    with :access_granted do
      it "updates the site's sections with the section params" do
        @section.reload.parent_id.should == @another_section.id
      end

      it "updates the section's paths" do
        @section.reload.path.should == "#{@another_section.path}/#{@section.permalink}"
      end

      # FIXME expire cache by site
    end
  end

  describe "DELETE to :destroy" do
    action do
      Section.with_observers :section_sweeper do
        delete :destroy, default_params.merge(:id => @section.id)
      end
    end

    it_guards_permissions :destroy, :section

    with :access_granted do
      it_assigns :site, :section
      it_destroys :section
      # FIXME implement: it_triggers_event :section_deleted
      it_redirects_to { new_admin_section_url(@site) } # FIXME should be admin_site_url(@site)
      it_sweeps_page_cache :by_site => :site
      it_assigns_flash_cookie :notice => :not_nil
    end
  end
end
