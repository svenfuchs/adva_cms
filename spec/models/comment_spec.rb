require File.dirname(__FILE__) + '/../spec_helper'

# describe Comment do
#   include Stubby, Matchers::ClassExtensions
#   
#   before :each do 
#     scenario :wiki_with_wikipages
#     
#     @comment = Comment.new :body => 'the body'
#     @comment.site = @site
#     @comment.section = @wiki
#     @comment.author = stub_user
#     @comment.commentable = @wikipage
#     @comment.commentable_type = 'Wiki'
#     @comment.commentable_id = @wikipage.id
#   end
#   
#   describe 'class extensions:' do
#     it 'acts as a role context for the author role' do
#       Comment.should act_as_role_context(:roles => :author)
#     end
#     
#     it 'sanitizes the body_html attribute' do
#       Comment.should filter_attributes(:sanitize => :body_html)
#     end
#     
#     it "filters the body column" do
#       @comment.should filter_column(:body)
#     end
#   end
#   
#   describe 'associations:' do  
#     it "belongs to a site" do
#       @comment.should belong_to(:site)
#     end
#     
#     it "belongs to a section" do
#       @comment.should belong_to(:section)
#     end
#     
#     it "belongs to a commentable" do
#       @comment.should belong_to(:commentable)
#     end
#   end
#   
#   describe 'validations:' do  
#     it "validates presence of author (through belongs_to_author)" do
#       @comment.should validate_presence_of(:author)
#     end
#   
#     it "validates presence of body" do
#       @comment.should validate_presence_of(:body)
#     end
#   
#     it "validates presence of commentable" do
#       @comment.should validate_presence_of(:commentable)
#     end
#   end
#   
#   describe 'callbacks:' do
#     it 'sets owners (site + section) before validation' do
#       Comment.before_validation.should include(:set_owners)
#     end
# 
#     it 'authorizes commenting before create' do
#       Comment.before_create.should include(:authorize_commenting)
#     end
# 
#     it 'updates the commentable after create' do
#       Comment.after_create.should include(:update_commentable)
#     end
# 
#     it 'updates the commentable after destroy' do
#       Comment.after_destroy.should include(:update_commentable)
#     end
#   end
#   
#   describe 'instance methods:' do
#     it '#owner returns the commentable' do
#       @comment.stub!(:commentable).and_return(@wikipage)
#       @comment.owner.should == @wikipage
#     end
#     
#     it '#filter returns the comment_filter attribute of the commentable' do
#       @comment.commentable.should_receive(:comment_filter)
#       @comment.filter
#     end
#     
#     describe '#approved?' do    
#       it 'returns true if the approved attribute is not 0' do
#         @comment.approved = 1
#         @comment.approved?.should be_true
#       end
#     
#       it 'returns true if the approved attribute is 0' do
#         @comment.approved = 0
#         @comment.approved?.should be_false
#       end
#     end
#     
#     describe '#authorize_commenting' do
#       it 'it checks if the commentable accepts comments' do
#         @comment.commentable.should_receive(:accept_comments?).and_return true
#         @comment.send :authorize_commenting
#       end
#       
#       it 'it raises CommentNotAllowed if the commentable does not accept comments' do
#         @comment.commentable.stub!(:accept_comments?).and_return false
#         lambda{ @comment.send :authorize_commenting }.should raise_error
#       end
#     end
#     
#     describe '#set_owners' do
#       it 'sets site from the commentable' do
#         @comment.commentable.should_receive(:site)
#         @comment.should_receive(:site=)
#         @comment.send :set_owners
#       end
# 
#       it 'sets section from the commentable' do
#         @comment.commentable.should_receive(:section)
#         @comment.should_receive(:section=)
#         @comment.send :set_owners
#       end
#     end
#     
#     it '#update_commentable calls #after_comment_update on the commentable' do
#       @comment.commentable.should_receive(:after_comment_update)
#       @comment.send :update_commentable
#     end
#   end
#   
#   it "returns a link as author_link when author_url is present" do
#     @comment.stub!(:author_homepage).and_return 'http://somewhere.com'
#     @comment.author_link.should == '<a href="http://somewhere.com">name</a>'
#   end
#   
#   it "returns author_name as author_link when author_url is not present" do
#     @comment.stub!(:author_homepage).and_return nil
#     @comment.author_link.should == 'name'
#   end
#   
#   it "calls commentable.accept_comments? before creating a comment" do
#     @wikipage.should_receive(:accept_comments?).and_return(false)
#     lambda { @comment.save! }.should raise_error
#   end
#   
#   it "raises Comment::CommentNotAllowed when commentable.accept_comments? returns false before creating a comment" do
#     @wikipage.stub!(:accept_comments?).and_return(false)
#     lambda { @comment.save! }.should raise_error(Comment::CommentNotAllowed)
#   end
# end

describe Comment, "spam control" do
  before :each do
    @report = SpamReport.new(:engine => name, :spaminess => 0, :data => {:spam => false, :spaminess => 0, :signature => 'signature'})
    @spam_engine = stub('spam_engine', :check_comment => @report)
    @section = stub('section', :spam_engine => @spam_engine, :approve_comments? => false)
    
    @comment = Comment.new
    @comment.stub!(:section).and_return @section
    @context = {:url => 'http://www.domain.org/an-article'}
  end
  
  describe "#check_approval" do
    it "saves the spam info hash as returned by Section#check_comment" do
      @comment.should_receive(:update_attributes).with hash_including(:spam_info => {:spam => false})
      @comment.check_approval @context
    end
    
    it "approves the comment when the spam info hash contains :spam => false" do
      @section.stub!(:check_comment).and_return :spam => false
      @comment.should_receive(:update_attributes).with hash_including(:approved => true)
      @comment.check_approval @context
    end
    
    it "disapproves the comment when the spam info hash contains :spam => true" do
      @section.stub!(:check_comment).and_return :spam => true
      @comment.should_receive(:update_attributes).with hash_including(:approved => false)
      @comment.check_approval @context
    end
    
    it "approves the comment when Section#approve_comments? is true" do
      @section.stub!(:approve_comments?).and_return true
      @comment.should_receive(:update_attributes).with hash_including(:approved => true)
      @comment.check_approval @context
    end
  end
  
  
  # before :each do
  #   @comment = comments(:a_comment)
  #   @comment.author = anonymouses(:an_anonymous) # wtf
  #   @comment.commentable = contents(:an_article)
  # end
  #   
  # describe '#check_comment' do
  #   it "approves the comment when the site's spam_option :engine is 'None' and approve_comments is true" do
  #     sites(:site_1).update_attributes :spam_options => {:engine => 'None', :approve_comments => true}
  #     @comment.check_approval('http://www.example.org/an-article', @comment)
  #     @comment.approved?.should be_true
  #   end
  # 
  #   it "does not approve the comment when the site's spam_option :engine is 'None' and approve_comments is not true" do
  #     sites(:site_1).update_attributes :spam_options => {:engine => 'None', :approve_comments => false}
  #     @comment.check_approval('http://www.example.org/an-article', @comment)
  #     @comment.approved?.should be_false
  #   end
  # 
  #   it "calls #check_comment on the None SpamEngine when the site's spam_option :engine is 'None'" do
  #     sites(:site_1).update_attributes :spam_options => {:engine => 'None', :approve_comments => false}
  #     @comment.section.site.spam_engine.should be_instance_of(SpamEngine::None)
  #     @comment.check_approval('http://www.example.org/an-article', @comment)
  #     @comment.spam_info.should == {}
  #   end
  # end
end