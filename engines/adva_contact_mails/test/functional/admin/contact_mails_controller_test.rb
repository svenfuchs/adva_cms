require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

module FunctionalTests
  class ContactMailsControllerTest < ActionController::TestCase
    tests Admin::ContactMailsController
  
    with_common :is_superuser, :a_site, :a_contact_mail
  
    test "is an Admin::BaseController" do
      @controller.should be_kind_of(Admin::BaseController)
    end
  
    describe "routing" do
      with_options :path_prefix => '/admin/sites/1/', :site_id => "1" do |r|
        r.it_maps :get,    "contact_mails",   :action => 'index'
        r.it_maps :get,    "contact_mails/1", :action => 'show',    :id => '1'
        r.it_maps :delete, "contact_mails/1", :action => 'destroy', :id => '1'
      end
    end
  
    describe "GET to index" do
      action { get :index, default_params }
    
      it_assigns :contact_mails
      it_assigns :menu
      it_renders :template, :index
    end
  
    describe "GET to show" do
      with "invalid contact mail id" do
        action { get :show, default_params.merge(:id => 'invalid') }
      
        it_redirects_to { admin_contact_mails_path(@site) }
        it_assigns_flash_cookie :error => :not_nil
      end
    
      with "valid contact mail id" do
        action { get :show, default_params.merge(:id => @contact_mail.id) }
      
        it_assigns :contact_mail
        it_assigns :menu
        it_renders :template, :show
      end
    end
  
    describe "DELETE to destroy" do
      with "no return_to params assigned" do
        action { delete :destroy, default_params.merge(:id => @contact_mail.id) }
    
        it_assigns :contact_mail
        it_assigns :menu
        it_assigns_flash_cookie :notice => :not_nil
        it_redirects_to { admin_contact_mails_path(@site) }
      end
    
      with "return_to params assigned" do
        action { delete :destroy, default_params.merge(:id => @contact_mail.id, :return_to => admin_sites_path) }
      
        it_redirects_to { admin_sites_path }
      end
    end
  
    def default_params
      { :site_id => @site.id }
    end
  end
end