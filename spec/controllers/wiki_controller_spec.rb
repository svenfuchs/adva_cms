require File.dirname(__FILE__) + "/../spec_helper"

describe WikiController do
  include SpecControllerHelper
  
  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end
  
  wiki_path          = '/de/wiki'
  pages_path         = '/de/wiki/pages'
  category_path      = '/de/wiki/categories/foo'
  tag_path           = '/de/wiki/tags/foo+bar'
  wikipage_path      = '/de/wiki/pages/a-wikipage'
  new_wikipage_path  = '/de/wiki/pages/new'
  edit_wikipage_path = '/de/wiki/pages/a-wikipage/edit'

  diff_path          = '/de/wiki/pages/a-wikipage/diff/1'
  revision_path      = '/de/wiki/pages/a-wikipage/rev/1'
  revision_diff_path = '/de/wiki/pages/a-wikipage/rev/1/diff/1'
  
  cached_paths = [wiki_path, pages_path, category_path, tag_path, wikipage_path]
  all_paths    = cached_paths + [revision_path, new_wikipage_path, edit_wikipage_path]
  
  before :each do
    scenario :site, :section, :wiki, :wikipage, :category, :tag, :user
    
    @site.sections.stub!(:find).and_return @wiki
    @wikipage.stub!(:new_record).and_return false
    
    @controller.stub!(:wiki_path).and_return wiki_path
    @controller.stub!(:wikipage_path).and_return wikipage_path
    @controller.stub!(:current_user).and_return stub_user
    # @controller.stub! :require_authentication    
    @controller.stub! :guard_permission
  end
  
  # TODO these overlap with specs in wiki_routes_spec  
  describe "routing" do
    with_options :section_id => "1", :locale => 'de' do |route|
      route.it_maps :get,    wiki_path,          :show
      route.it_maps :get,    wikipage_path,      :show,    :id => 'a-wikipage'
      route.it_maps :get,    revision_path,      :show,    :id => 'a-wikipage', :version => '1'
      route.it_maps :get,    diff_path,          :diff,    :id => 'a-wikipage', :diff_version => '1'
      route.it_maps :get,    revision_diff_path, :diff,    :id => 'a-wikipage', :version => '1', :diff_version => '1'
      
      route.it_maps :get,    pages_path,         :index
      route.it_maps :get,    category_path,      :index,   :category_id => '1'
      route.it_maps :get,    tag_path,           :index,   :tags => 'foo+bar'
      
      route.it_maps :get,    new_wikipage_path,  :new
      route.it_maps :post,   pages_path,         :create
      route.it_maps :get,    edit_wikipage_path, :edit,    :id => 'a-wikipage'
      route.it_maps :put,    wikipage_path,      :update,  :id => 'a-wikipage'
      route.it_maps :delete, wikipage_path,      :destroy, :id => 'a-wikipage'
    end
  end  

  cached_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }    
      it_gets_page_cached
    end
  end
  
  describe "GET to #{pages_path}" do
    act! { request_to :get, pages_path }    
    it_assigns :wikipages
    it_renders_template :index
  end  
  
  describe "GET to #{category_path}" do
    act! { request_to :get, category_path }    
    it_assigns :category
  end  
  
  describe "GET to #{tag_path}" do
    act! { request_to :get, tag_path }    
    it_assigns :tags
  end  
  
  describe "GET to #{wikipage_path}" do
    act! { request_to :get, wikipage_path }    
    
    describe "with a non-existing wikipage" do
      before :each do
        @wikipage = Wikipage.new
        @wiki.wikipages.stub!(:find_or_initialize_by_permalink).and_return @wikipage
        controller.stub!(:has_permission?).with(:manage_wikipages).and_return true
      end
      it_assigns :wikipage, :categories
    
      describe "and the current user having sufficient permissions to add a page" do
        it_renders_template :new
      end
    
      describe "and the current user not having sufficient permissions to add a page" do
        before :each do
          controller.stub!(:has_permission?).with(:manage_wikipages).and_return false
        end
        it_redirects_to { login_path }
      end
    end
    
    describe "with an existing wikipage" do
      it_assigns :wikipage
      it_renders_template :show
    end
  end  

  describe "GET to #{revision_path}" do
    act! { request_to :get, revision_path }    
    
    it "reverts the wikipage to the given version" do
      @wikipage.should_receive(:revert_to).at_least :once
      act!
    end
  end  

  describe "GET to #{diff_path}" do
    act! { request_to :get, diff_path }    
    it_assigns :wikipage, :diff => 'the diff'
    
    it "diffs the wikipage against the given version" do
      @wikipage.should_receive(:diff_against_version)
      act!
    end
  end

  describe "GET to #{revision_diff_path}" do
    act! { request_to :get, revision_diff_path }    
    it_assigns :wikipage, :diff => 'the diff'
    
    it "reverts the wikipage to the given version" do
      @wikipage.should_receive(:revert_to).at_least :once
      act!
    end
    
    it "diffs the wikipage against the given version" do
      @wikipage.should_receive(:diff_against_version)
      act!
    end
  end
  
  describe "GET to #{edit_wikipage_path}" do
    act! { request_to :get, edit_wikipage_path }    
    it_assigns :wikipage, :categories
    it_renders_template :edit
  end
  
  describe "POST to :create" do
    act! { request_to :post, pages_path, :wikipage => {} }    
    it_assigns :wikipage
    
    it "instantiates a new wikipage from section.wikipages" do
      @wiki.wikipages.should_receive(:create).and_return @wikipage
      act!
    end
    
    describe "given valid wikipage params" do
      it_redirects_to { wikipage_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid wikipage params" do
      before :each do @wiki.wikipages.should_receive(:create).and_return false end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
    end    
  end
  
  describe "PUT to :update" do
    before :each do 
      controller.stub!(:optimistic_lock)
    end
    
    act! { request_to :put, wikipage_path, :wikipage => {} }    
    it_assigns :wikipage    
    
    it "updates the wikipage with the wikipage params" do
      @wikipage.should_receive(:update_attributes).and_return true
      act!
    end
    
    describe "given valid wikipage params" do
      it_redirects_to { wikipage_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "given invalid wikipage params" do
      before :each do @wikipage.stub!(:update_attributes).and_return false end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
    end
  end
  
  describe "DELETE to :destroy" do
    act! { request_to :delete, wikipage_path }    
    it_assigns :wikipage
    
    it "should try to destroy the wikipage" do
      @wikipage.should_receive :destroy
      act!
    end 
    
    describe "when destroy succeeds" do
      it_redirects_to { wiki_path }
      it_assigns_flash_cookie :notice => :not_nil
    end
    
    describe "when destroy fails" do
      before :each do @wikipage.stub!(:destroy).and_return false end
      it_renders_template :show
      it_assigns_flash_cookie :error => :not_nil
    end
  end  
end  
