require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::UsersController do
  include SpecControllerHelper
  
  it "should be an Admin::BaseController" do
    controller.should be_kind_of(Admin::BaseController)
  end
  
  ['', 'sites/1/'].each do |scope|
    describe "with scope #{scope.inspect}" do
  
      before :each do
        scenario :site, :section, :article, :user
        set_resource_paths :user, "/admin/#{scope}"
    
        @controller.stub! :require_authentication
        @controller.stub! :authorize_access # TODO ???
        @controller.stub! :guard_permission
      end
  
      describe "routing" do
        options = {:path_prefix => "/admin/#{scope}"}
        options[:site_id] = "1" unless scope.blank?
      
        with_options options do |route|
          route.it_maps :get, "users", :index
          route.it_maps :get, "users/1", :show, :id => '1'
          route.it_maps :get, "users/new", :new
          route.it_maps :post, "users", :create
          route.it_maps :get, "users/1/edit", :edit, :id => '1'
          route.it_maps :put, "users/1", :update, :id => '1'
          route.it_maps :delete, "users/1", :destroy, :id => '1'
        end
      end 
  
      describe "GET to :index" do
        act! { request_to :get, @collection_path }    
        it_assigns :users
        it_renders_template :index
      end
  
      describe "GET to :show" do
        act! { request_to :get, @member_path }    
        it_assigns :user
        it_renders_template :show
      end
  
      describe "GET to :new" do
        act! { request_to :get, @new_member_path }    
        it_assigns :user
        it_renders_template :new
        
        it "instantiates a new user from section.users" do
          User.should_receive(:new).and_return @user
          act!
        end    
      end
      
      describe "POST to :create" do
        act! { request_to :post, @collection_path }    
        it_assigns :user
        
        if scope.blank?
          it "instantiates a new user from User" do
            User.should_receive(:new).and_return @user
            act!
          end
        else
          it "instantiates a new user from site.users" do
            @site.users.should_receive(:build).and_return @user
            act!
          end
        end
        
        describe "given valid user params" do
          it_redirects_to { @member_path }
          it_assigns_flash_cookie :notice => :not_nil
        end
        
        describe "given invalid user params" do
          before :each do @user.stub!(:update_attributes).and_return false end
          it_renders_template :new
          it_assigns_flash_cookie :error => :not_nil
        end    
      end
       
      describe "GET to :edit" do
        act! { request_to :get, @edit_member_path }    
        it_assigns :user
        it_renders_template :edit
        
        it "fetches a user from User" do
          User.should_receive(:find).and_return @user
          act!
        end  
      end 

      describe "PUT to :update" do
        act! { request_to :put, @member_path }    
        it_assigns :user    
    
        it "fetches a user from User" do
          User.should_receive(:find).and_return @user
          act!
        end  
    
        it "updates the user with the user params" do
          @user.should_receive(:update_attributes).and_return true
          act!
        end
    
        describe "given valid user params" do
          it_redirects_to { @member_path }
          it_assigns_flash_cookie :notice => :not_nil
        end
    
        describe "given invalid user params" do
          before :each do @user.stub!(:update_attributes).and_return false end
          it_renders_template :edit
          it_assigns_flash_cookie :error => :not_nil
        end
      end

      describe "DELETE to :destroy" do
        act! { request_to :delete, @member_path }    
        it_assigns :user
    
        it "fetches a user from User" do
          User.should_receive(:find).and_return @user
          act!
        end  
    
        it "should try to destroy the user" do
          @user.should_receive :destroy
          act!
        end 
    
        describe "when destroy succeeds" do
          it_redirects_to { @collection_path }
          it_assigns_flash_cookie :notice => :not_nil
        end
    
        describe "when destroy fails" do
          before :each do @user.stub!(:destroy).and_return false end
          it_renders_template :edit
          it_assigns_flash_cookie :error => :not_nil
        end
      end
    end
  end
end