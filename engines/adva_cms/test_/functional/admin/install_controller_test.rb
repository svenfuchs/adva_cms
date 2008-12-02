require File.dirname(__FILE__) + '/../../test_helper'

module With::Dsl
  [:it_renders, :it_redirects_to, :it_assigns, :it_changes, :it_saves].each do |name|
    module_eval %(
      def #{name}(*args, &block)
        assertion do
          #{name}(*args, &block)
        end
      end
    )
  end
end

class AdminInstallControllerTest < ActionController::TestCase
  tests Admin::InstallController

  describe "the before_filter normalize_params" do
    it "sets params[:site][:host] to the current request.host_with_port" do
      @controller.send(:normalize_install_params)
      @controller.params[:site][:host].should == @request.host_with_port
    end
  end

  test "routes" do
    with_options :controller => 'admin/install', :action => 'index' do |r|
      r.it_maps :get, '/'
      r.it_maps :post, '/'
      r.it_maps :get, '/admin/install'
      r.it_maps :post, '/admin/install'
      r.it_generates '/admin/install'
    end
  end
  
  share :no_site do
    before { Site.delete_all }
  end
  
  share :an_empty_site do
    before { @site = Site.make }
  end
  
  share :valid_install_params do
    before do
      @params = { :site    => {:name => 'site name'},
                  :section => {:type => 'Section', :title => 'section title'},
                  :user    => {:email => 'admin@admin.org', :password => 'password'} }
    end
  end
  
  share :install_params_missing_site_name do
    before do
      @params = { :site    => { },
                  :section => {:type => 'Section', :title => 'section title'},
                  :user    => {:email => 'admin@admin.org', :password => 'password'} }
    end
  end

  share :install_params_missing_section_title do
    before do
      @params = { :site    => {:name => 'site name'},
                  :section => {:type => 'Section'},
                  :user    => {:email => 'admin@admin.org', :password => 'password'} }
    end
  end

  share :install_params_missing_admin_email do
    before do
      @params = { :site    => {:name => 'site name'},
                  :section => {:type => 'Section'},
                  :user    => {:password => 'password'} }
    end
  end

  describe "GET to :index" do
    action { get :index }
    
    with :no_site do
      it "displays the install form" do
        it_assigns :site, :section, :user
        it_renders :template, "admin/install"

        it "assigns the root section to the site" do
          assigns(:site).sections.first.should_not == nil
        end
      end
    end
    
    with :an_empty_site do
      # it redirects somewhere?
    end
  end
  
  describe "POST to :index" do
    action { post :index, @params }
  
    with :valid_install_params do
      it_renders :template, 'admin/install/confirmation'
      it_saves :site, :section, :user

      # it_changes 'Site.count' => 1, 'Section.count' => 1, 'User.count' => 1 do
      #   post :index, @params
      # end
      
      it "assigns the new Section to the new Site" do
        assigns(:section).reload.site.should_not == nil
      end
      
      it "makes the new User a :superuser" do
        Rbac::Role::Superuser.should === assigns(:user).reload.roles.first
      end
      
      it "authenticates the current user as the new User" do
        @controller.current_user.should_not == nil
      end
    end
  
    with :install_params_missing_site_name do
      it_renders :template, 'admin/install'
#      it_assigns_flash_cookie :error => :not_nil
#      it_does_not_save :site
    end
  end
  
  # test "POST :index with invalid section params" do
  #   post :index, :site => {:name => 'Site name'},
  #                :user => {:email => 'admin@admin.org', :password => 'password'}
  #                
  #   it_renders_template 'admin/install'
  #   # it_assigns_flash_cookie :error => :not_nil
  #   it_does_not_save :section
  # end
  # 
  # # TODO make this true. currently user validation in admin/install doesn't work
  # #
  # # test "POST :index with invalid user params" do
  # #   post :index, :site => {:name => 'Site name'},
  # #                :section => {:type => 'Section', :title => 'section title'}
  # #                
  # #   it_renders_template 'admin/install'
  # #   # it_assigns_flash_cookie :error => :not_nil
  # #   it_does_not_save :user
  # # end
end