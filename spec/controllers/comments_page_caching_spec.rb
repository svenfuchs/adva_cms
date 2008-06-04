require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "Comment page_caching" do
  include SpecControllerHelper
  
  # describe BaseController do    
  #   it "page caches the comments action with reference tracking" do
  #     BaseController.should_receive(:caches_page_with_references) do |*args|
  #       args.should include(:comments)
  #     end
  #     load 'base_controller.rb'
  #   end
  #   
  #   it "tacks commentable models read access" do
  #     BaseController.should_receive(:caches_page_with_references) do |*args|
  #       options = args.extract_options!
  #       options[:track].should == ['@commentable']
  #     end
  #     load 'base_controller.rb'
  #   end
  # end
  
  describe CommentsController do    
    before :each do
      @sweeper = CommentsController.filter_chain.find CommentSweeper.instance
    end
    
    it "activates the CommentSweeper as an around filter" do
      @sweeper.should be_kind_of(ActionController::Filters::AroundFilter)
    end
      
    it "configures the CommentSweeper to observe Comment create, update and destroy events" do
      @sweeper.options[:only].should == [:create, :update, :destroy]
    end
  end
  
  describe "CommentSweeper" do
    controller_name 'comments'
  
    before :each do
      scenario :section, :comment
      @sweeper = CommentSweeper.instance
      @comment.stub!(:commentable).and_return @section
    end
    
    it "observes Comment" do 
      ActiveRecord::Base.observers.should include(:comment_sweeper)
    end
    
    it "expires pages that reference a comment's commentable when the comment was saved" do
      @sweeper.should_receive(:expire_cached_pages_by_reference).with(@section)
      @sweeper.after_save(@comment)
    end
  end
end