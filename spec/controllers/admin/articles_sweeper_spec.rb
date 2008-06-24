require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "Article page sweeping" do
  include SpecControllerHelper
  
  describe Admin::ArticlesController do    
    before :each do
      @filter = Admin::ArticlesController.filter_chain.find ArticleSweeper.instance      
    end
    
    it "activates the ArticleSweeper as an around filter" do
      @filter.should be_kind_of(ActionController::Filters::AroundFilter)
    end
      
    it "configures the ArticleSweeper to observe Comment create, update, rollback and destroy events" do
      @filter.options[:only].should == [:create, :update, :destroy]
    end
  end
  
  describe "ArticleSweeper" do
    controller_name 'admin/articles'

    before :each do
      scenario :article
      @sweeper = ArticleSweeper.instance
    end
    
    it "observes Article" do 
      ActiveRecord::Base.observers.should include(:article_sweeper)
    end
    
    it "should expire pages that reference an article when an article was saved" do
      @sweeper.should_receive(:expire_cached_pages_by_reference).with(@article)
      @sweeper.after_save(@article)
    end
  end
end