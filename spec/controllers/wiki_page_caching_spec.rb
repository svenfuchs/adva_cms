require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Wiki page_caching" do
  include SpecControllerHelper
  
  describe WikiController do
    before :each do
      @wikipage_sweeper = WikiController.filter_chain.find WikipageSweeper.instance
      @category_sweeper = WikiController.filter_chain.find CategorySweeper.instance
      @tag_sweeper = WikiController.filter_chain.find TagSweeper.instance
    end
    
    it "activates the WikipageSweeper as an around filter" do
      @wikipage_sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
    end
      
    it "configures the WikipageSweeper to observe Comment create, update, rollback and destroy events" do
      @wikipage_sweeper.options[:only].should == [:create, :update, :rollback, :destroy]
    end
    
    it "activates the CategorySweeper as an around filter" do
      @category_sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
    end
      
    it "configures the CategorySweeper to observe Comment create, update, rollback and destroy events" do
      @category_sweeper.options[:only].should == [:create, :update, :rollback, :destroy]
    end
    
    it "activates the TagSweeper as an around filter" do
      @tag_sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
    end
      
    it "configures the TagSweeper to observe Comment create, update, rollback and destroy events" do
      @tag_sweeper.options[:only].should == [:create, :update, :rollback, :destroy]
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
    controller_name 'wiki'

    before :each do
      scenario :wiki, :wikipage
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
end