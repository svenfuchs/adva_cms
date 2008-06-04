require File.dirname(__FILE__) + "/../../spec_helper"

describe Admin::InstallController do
  include SpecControllerHelper
  
  before :each do
    scenario :site, :section, :article, :user
    
    User.stub!(:find).and_return nil
    Site.stub!(:find).and_return nil
    Site.stub!(:new).and_return @site
    
    @site.sections.stub!(:<<)
    
    controller.stub!(:authenticate_user)
    @install_path = '/admin/install'
  end
  
  describe "routing" do
    it_maps :get, "/admin/install", :index
    it_maps :post, "/admin/install", :index
  end
  
  describe "GET to :index" do
    act! { request_to :get, @install_path }    
    it_assigns :site, :section
    it_renders_template :index
    
    it "instantiates a new site" do
      Site.should_receive(:new).and_return @site
      act!
    end
    
    it "instantiates a new section" do
      @site.sections.should_receive(:build).and_return @section
      act!
    end
  end
  
  describe "POST to :index" do
    act! { request_to :post, @install_path }    
    it_assigns :site, :section
      
    it "instantiates a site from Site" do
      Site.should_receive(:new).and_return @site
      act!
    end
      
    it "instantiates a section from site.sections" do
      @site.sections.should_receive(:build).and_return @section
      act!
    end
      
    it "adds the section to site.sections" do
      @site.sections.should_receive(:<<).with @section
      act!
    end
    
    describe "given valid site and section params" do
      it_assigns_flash_cookie :notice => :not_nil
      it_renders_template :confirmation
      
      it "saves the site" do
        @site.should_receive(:save)
        act!
      end
      
      it "creates an admin user account" do
        User.should_receive(:create_superuser).and_return @user
        act!
      end
  
      it "authenticates the admin user account" do
        controller.should_receive(:authenticate_user)
        act!
      end     
    end
    
    describe "given invalid site params" do
      before :each do @site.stub!(:valid?).and_return false end
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template :index
      
      it "does not save the site" do
        @site.should_not_receive(:save)
        act!
      end
    end    
    
    describe "given invalid section params" do
      before :each do @section.stub!(:valid?).and_return false end
      it_assigns_flash_cookie :error => :not_nil
      it_renders_template :index
      
      it "does not save the site" do
        @site.should_not_receive(:save)
        act!
      end
    end    
  end
end