require File.dirname(__FILE__) + '/../../spec_helper.rb'

describe "Article page sweeping" do
  include SpecControllerHelper
  
  describe Admin::ArticlesController do    
    before :each do
      @article_sweeper = Admin::ArticlesController.filter_chain.find ArticleSweeper.instance      
    end
    
    it "activates the WikipageSweeper as an around filter" do
      @article_sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
    end
      
    it "configures the WikipageSweeper to observe Comment create, update, rollback and destroy events" do
      @article_sweeper.options[:only].should == [:create, :update, :destroy]
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