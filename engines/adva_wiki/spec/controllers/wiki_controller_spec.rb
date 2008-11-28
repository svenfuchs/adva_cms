require File.dirname(__FILE__) + "/../spec_helper"

wiki_path            = '/wikis/1'
wiki_pages_path      = '/wikis/1/pages'
wiki_category_path   = '/wikis/1/categories/1'
wiki_tag_path        = '/wikis/1/tags/foo+bar'
wiki_page_path       = '/wikis/1/pages/a-wikipage'
new_wikipage_path    = '/wikis/1/pages/new'
edit_wikipage_path   = '/wikis/1/pages/a-wikipage/edit'

wiki_page_diff_path            = '/wikis/1/pages/a-wikipage/diff/1'
wiki_page_revision_path        = '/wikis/1/pages/a-wikipage/rev/1'
wiki_page_revision_diff_path   = '/wikis/1/pages/a-wikipage/rev/1/diff/1'

wikipages_feed_paths = %w( /wikis/1.atom
                           /wikis/1/pages/a-wikipage.atom )
comments_feed_paths  = %w( /wikis/1/comments.atom
                           /wikis/1/pages/a-wikipage/comments.atom )

cached_paths = [wiki_path, wiki_pages_path, wiki_category_path, wiki_tag_path, wiki_page_path]
all_paths    = cached_paths + [wiki_page_revision_path, new_wikipage_path, edit_wikipage_path]


describe WikiController do
  include SpecControllerHelper

  before :each do
    stub_scenario :wiki_with_wikipages, :user_logged_in

    controller.stub!(:wiki_path).and_return wiki_path
    controller.stub!(:wikipage_path).and_return wiki_page_path

    controller.stub!(:has_permission?).and_return true
  end

  it "should be a BaseController" do
    controller.should be_kind_of(BaseController)
  end
  
  # TODO these overlap with specs in wiki_routes_spec
  describe "routing" do
    with_options :section_id => "1" do |route|
      route.it_maps :get,    wiki_path,                    :show
      route.it_maps :get,    wiki_page_path,               :show,    :id => 'a-wikipage'
      route.it_maps :get,    wiki_page_revision_path,      :show,    :id => 'a-wikipage', :version => '1'
      route.it_maps :get,    wiki_page_diff_path,          :diff,    :id => 'a-wikipage', :diff_version => '1'
      route.it_maps :get,    wiki_page_revision_diff_path, :diff,    :id => 'a-wikipage', :version => '1', :diff_version => '1'
  
      route.it_maps :get,    wiki_pages_path,              :index
      route.it_maps :get,    wiki_category_path,           :index,   :category_id => '1'
      route.it_maps :get,    wiki_tag_path,                :index,   :tags => 'foo+bar'
  
      route.it_maps :get,    new_wikipage_path,            :new
      route.it_maps :post,   wiki_pages_path,              :create
      route.it_maps :get,    edit_wikipage_path,           :edit,    :id => 'a-wikipage'
      route.it_maps :put,    wiki_page_path,               :update,  :id => 'a-wikipage'
      route.it_maps :delete, wiki_page_path,               :destroy, :id => 'a-wikipage'
    end
  end
  
  cached_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_gets_page_cached
    end
  end
  
  describe "GET to #{wiki_pages_path}" do
    act! { request_to :get, wiki_pages_path }
    it_assigns :wikipages
    it_renders_template :index
    # it_guards_permissions :show, :wikipage
  end
  
  describe "GET to #{wiki_category_path}" do
    act! { request_to :get, wiki_category_path }
    it_assigns :category
    # it_guards_permissions :show, :wikipage
  end
  
  describe "GET to #{wiki_tag_path}" do
    act! { request_to :get, wiki_tag_path }
    it_assigns :tags
    # it_guards_permissions :show, :wikipage
  end
  
  describe "GET to #{wiki_page_path}" do
    act! { request_to :get, wiki_page_path }
  
    describe "with a non-existing wikipage" do
      before :each do
        @wikipage = Wikipage.new
        @wiki.wikipages.stub!(:find_or_initialize_by_permalink).and_return @wikipage
        controller.stub!(:has_permission?).and_return true
      end
      it_guards_permissions :create, :wikipage
      it_assigns :wikipage, :categories
  
      describe "and the current user having sufficient permissions to add a page" do
        it_renders_template :new
  
        it "it skips page_caching" do
          controller.should_receive(:render).with hash_including(:skip_caching => true)
          act!
        end
      end
  
      describe "and the current user not having sufficient permissions to add a page" do
        before :each do
          controller.stub!(:has_permission?).and_return false
        end
        it_redirects_to { login_url(:return_to => request.url) }
      end
    end
  
    describe "with an existing wikipage" do
      it_assigns :wikipage
      it_renders_template :show
      # it_guards_permissions :show, :wikipage
    end
  end
  
  describe "GET to #{wiki_page_revision_path}" do
    act! { request_to :get, wiki_page_revision_path }
    # it_guards_permissions :show, :wikipage
  
    it "reverts the wikipage to the given version" do
      @wikipage.should_receive(:revert_to).at_least :once
      act!
    end
  end
  
  describe "GET to #{wiki_page_diff_path}" do
    act! { request_to :get, wiki_page_diff_path }
    it_assigns :wikipage, :diff => 'the diff'
    # it_guards_permissions :show, :wikipage
  
    it "diffs the wikipage against the given version" do
      @wikipage.should_receive(:diff_against_version)
      act!
    end
  end
  
  describe "GET to #{wiki_page_revision_diff_path}" do
    act! { request_to :get, wiki_page_revision_diff_path }
    it_assigns :wikipage, :diff => 'the diff'
    # it_guards_permissions :show, :wikipage
  
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
    it_guards_permissions :update, :wikipage
    it_assigns :wikipage, :categories
    it_renders_template :edit
  end
  
  describe "POST to :create" do
    before :each do
      @wikipage.stub!(:state_changes).and_return([:created])
    end
  
    act! { request_to :post, wiki_pages_path, :wikipage => {} }
    it_guards_permissions :create, :wikipage
    it_assigns :wikipage
  
    it "instantiates a new wikipage from section.wikipages" do
      @wiki.wikipages.should_receive(:create).and_return @wikipage
      act!
    end
  
    describe "given valid wikipage params" do
      it_redirects_to { wikipage_path }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :wikipage_created
    end
  
    describe "given invalid wikipage params" do
      before :each do
        @wiki.wikipages.should_receive(:create).and_return false
      end
      it_renders_template :new
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end
  
  describe "PUT to :update", "with no :version param" do
    before :each do
      controller.stub!(:optimistic_lock)
      @wikipage.stub!(:state_changes).and_return([:updated])
    end
  
    act! { request_to :put, wikipage_path, :wikipage => {} }
    it_guards_permissions :update, :wikipage
    it_assigns :wikipage
  
    it "updates the wikipage with the wikipage params" do
      @wikipage.should_receive(:update_attributes).and_return true
      act!
    end
  
    describe "given valid wikipage params" do
      it_redirects_to { wikipage_path }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :wikipage_updated
    end
  
    describe "given invalid wikipage params" do
      before :each do
        @wikipage.stub!(:update_attributes).and_return false
      end
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end

  describe "PUT to :update", "with a :version param" do
    before :each do
      controller.stub!(:optimistic_lock)
      @wikipage.stub!(:revert_to).and_return true
      @wikipage.stub!(:save).and_return true
    end

    act! { request_to :put, wikipage_path, { :version => 1 } }
    it_guards_permissions :update, :wikipage
    it_assigns :wikipage

    it "tries to roll the wikipage back to the given version" do
      @wikipage.should_receive(:revert_to).and_return true
      act!
    end

    describe "given the wikipage can be rolled back the given version" do
      it_redirects_to { wikipage_path }
      it_assigns_flash_cookie :notice => :not_nil
      it_triggers_event :wikipage_rolledback
    end
    
    describe "given the wikipage can not be rolled back the given version" do
      before :each do
        @wikipage.stub!(:revert_to).and_return false
        @wikipage.stub!(:save).and_return false
      end
    
      it_renders_template :edit
      it_assigns_flash_cookie :error => :not_nil
      it_does_not_trigger_any_event
    end
  end

  describe "DELETE to :destroy" do
    before :each do
      @wikipage.stub!(:state_changes).and_return([:deleted])
    end

    act! { request_to :delete, wikipage_path }
    it_guards_permissions :destroy, :wikipage
    it_assigns :wikipage
    it_triggers_event :wikipage_deleted

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

describe WikiController, 'feeds' do
  include SpecControllerHelper

  before :each do
    stub_scenario :wiki_with_wikipages, :user_logged_in
    controller.stub!(:has_permission?).and_return true # TODO
  end

  # TODO implement wikipage updates feed
  # wikipages_feed_paths.each do |path|
  #   describe "GET to #{path}" do
  #     act! { request_to :get, path }
  #     it_renders_template 'show', :format => :atom
  #     it_guards_permissions :show, :wikipage
  #   end
  # end

  comments_feed_paths.each do |path|
    describe "GET to #{path}" do
      act! { request_to :get, path }
      it_renders_template 'comments/comments', :format => :atom
      it_gets_page_cached
      # it_guards_permissions :show, :wikipage
    end
  end
end

describe WikiController, 'page_caching' do
  include SpecControllerHelper

  before :each do
    @wikipage_sweeper = WikiController.filter_chain.find WikipageSweeper.instance
    @category_sweeper = WikiController.filter_chain.find CategorySweeper.instance
    @tag_sweeper = WikiController.filter_chain.find TagSweeper.instance
  end

  it "activates the WikipageSweeper as an around filter" do
    @wikipage_sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
  end

  it "configures the WikipageSweeper to observe Comment create, update, rollback and destroy events" do
    @wikipage_sweeper.options[:only].to_a.sort.should == ['create', 'destroy', 'rollback', 'update']
  end

  it "activates the CategorySweeper as an around filter" do
    @category_sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
  end

  it "configures the CategorySweeper to observe Comment create, update, rollback and destroy events" do
    @category_sweeper.options[:only].to_a.sort.should == ['create', 'destroy', 'rollback', 'update']
  end

  it "activates the TagSweeper as an around filter" do
    @tag_sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
  end

  it "configures the TagSweeper to observe Comment create, update, rollback and destroy events" do
    @tag_sweeper.options[:only].to_a.sort.should == ['create', 'destroy', 'rollback', 'update']
  end

  it "tracks read access for a bunch of models for the :index action page caching" do
    WikiController.track_options[:index].should == ['@wikipage', '@wikipages', '@category', {"@section" => :tag_counts, "@site" => :tag_counts}]
  end

  it "page_caches the :show action" do
    cached_page_filter_for(:show).should_not be_nil
  end

  it "tracks read access for a bunch of models for the :show action page caching" do
    WikiController.track_options[:show].should == ['@wikipage', '@wikipages', '@category', {"@section" => :tag_counts, "@site" => :tag_counts}]
  end

  it "page_caches the comments action" do
    cached_page_filter_for(:comments).should_not be_nil
  end

  it "tracks read access on @commentable for comments action page caching" do
    WikiController.track_options[:comments].should include('@commentable')
  end
end

describe "WikipageSweeper" do
  include SpecControllerHelper
  controller_name 'wiki'

  before :each do
    stub_scenario :wiki_with_wikipages
    @sweeper = WikipageSweeper.instance
  end

  it "observes Wikipage" do
    ActiveRecord::Base.observers.should include(:wikipage_sweeper)
  end

  it "should expire pages that reference a wikipage's section when the home wikipage was saved" do
    @wikipage.should_receive(:home?).and_return true
    @sweeper.should_receive(:expire_cached_pages_by_section).with(@wiki)
    @sweeper.after_save(@wikipage)
  end

  it "should expire pages that reference an wikipage when a non-home wikipage was saved" do
    @sweeper.should_receive(:expire_cached_pages_by_reference).with(@wikipage)
    @sweeper.after_save(@wikipage)
  end
end