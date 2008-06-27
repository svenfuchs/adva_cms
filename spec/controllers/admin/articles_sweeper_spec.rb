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
    
    it "should expire pages that reference the article's section when the article is a new record" do
      @article.stub!(:new_record?).and_return true
      @sweeper.should_receive(:expire_cached_pages_by_reference).with(@article.section)
      @sweeper.before_save(@article)
    end
    
    it "should expire pages that reference an article when the article is not a new record" do
      @article.stub!(:new_record?).and_return false
      @sweeper.should_receive(:expire_cached_pages_by_reference).with(@article)
      @sweeper.before_save(@article)
    end
  end
end