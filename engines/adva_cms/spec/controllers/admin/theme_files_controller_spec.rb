require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::ThemeFilesController do
  include SpecControllerHelper

  before :each do
    stub_scenario :empty_site, :theme_with_files
    @theme_path = '/admin/sites/1/themes/theme-1'
    set_resource_paths :file, "#{@theme_path}/"

    @controller.stub! :require_authentication
    @controller.stub!(:has_permission?).and_return true
    @controller.stub! :expire_pages
  end

  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end

  describe "routing" do
    with_options :path_prefix => '/admin/sites/1/themes/theme-1/', :site_id => "1" do |route|
      # route.it_maps :get, "files", :index, :theme_id => 'theme-1'
      route.it_maps :get, "files/something-erb-html", :show, :theme_id => 'theme-1', :id => 'something-erb-html'
      route.it_maps :get, "files/new", :new, :theme_id => 'theme-1'
      route.it_maps :post, "files", :create, :theme_id => 'theme-1'
      route.it_maps :get, "files/something-erb-html/edit", :edit, :theme_id => 'theme-1', :id => 'something-erb-html'
      route.it_maps :put, "files/something-erb-html", :update, :theme_id => 'theme-1', :id => 'something-erb-html'
      route.it_maps :delete, "files/something-erb-html", :destroy, :theme_id => 'theme-1', :id => 'something-erb-html'
    end
  end

  describe "GET to :show" do
    act! { request_to :get, @member_path }
    # it_guards_permissions :update, :theme
    it_assigns :file
  end

  describe "POST to :create" do
    act! { request_to :post, @collection_path }
    it_guards_permissions :update, :theme
    it_assigns :file

    it "creates a new file from Theme::File" do
      Theme::File.should_receive(:create).and_return @file
      act!
    end

    describe "given valid params" do
      it_redirects_to { @member_path }
      it_assigns_flash_cookie :notice => :not_nil

      it "expires page cache for the current site" do
        controller.should_receive(:expire_site_page_cache)
        act!
      end
    end

    describe "given invalid params" do
      before :each do Theme::File.stub!(:create).and_return false end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "PUT to :update" do
    act! { request_to :put, @member_path }
    it_guards_permissions :update, :theme
    it_assigns :file

    it "fetches a file from @theme.files" do
      @theme.files.should_receive(:find).and_return @file
      act!
    end

    it "updates the file with the file params" do
      @file.should_receive(:update_attributes).and_return true
      act!
    end

    describe "given valid file params" do
      it_redirects_to { @member_path }
      it_assigns_flash_cookie :notice => :not_nil

      it "expires page cache for the current site" do
        controller.should_receive(:expire_site_page_cache)
        act!
      end
    end

    describe "given invalid file params" do
      before :each do @file.stub!(:update_attributes).and_return false end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end

  describe "DELETE to :destroy" do
    act! { request_to :delete, @member_path }
    it_guards_permissions :update, :theme
    it_assigns :file

    it "fetches a file from @theme.files" do
      @theme.files.should_receive(:find).and_return @file
      act!
    end

    it "should try to destroy the file" do
      @file.should_receive :destroy
      act!
    end

    describe "when destroy succeeds" do
      it_redirects_to { @theme_path }
      it_assigns_flash_cookie :notice => :not_nil

      it "expires page cache for the current site" do
        controller.should_receive(:expire_site_page_cache)
        act!
      end
    end

    describe "when destroy fails" do
      before :each do @file.stub!(:destroy).and_return false end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end
end

