require File.dirname(__FILE__) + '/../../test_helper'

class CommentTest < ActiveSupport::TestCase
  def setup
    super
    @section = Section.first
    @article = @section.articles.first
    @comment = @article.comments.first
  end

  test 'acts as a role context for the author role' do
    Comment.should act_as_role_context(:roles => :author)
  end
  
  test 'sanitizes the body_html attribute' do
    Comment.should filter_attributes(:sanitize => :body_html)
  end
  
  test "filters the body column" do
    @comment.should filter_column(:body)
  end
  
  # ASSOCIATIONS
  
  test "belongs to a site" do
    @comment.should belong_to(:site)
  end
  
  test "belongs to a section" do
    @comment.should belong_to(:section)
  end
  
  test "belongs to a commentable" do
    @comment.should belong_to(:commentable)
  end
  
  # VALIDATIONS
  
  test "validates presence of author (through belongs_to_author)" do
    @comment.should validate_presence_of(:author)
  end
  
  test "validates presence of body" do
    @comment.should validate_presence_of(:body)
  end
  
  test "validates presence of commentable" do
    @comment.should validate_presence_of(:commentable)
  end
  
  # CALLBACKS
  
  test 'sets owners (site + section) before validation' do
    Comment.before_validation.should include(:set_owners)
  end
  
  test 'authorizes commenting before create' do
    Comment.before_create.should include(:authorize_commenting)
  end
  
  test 'updates the commentable after create' do
    Comment.after_save.should include(:update_commentable)
  end
  
  test 'updates the commentable after destroy' do
    Comment.after_destroy.should include(:update_commentable)
  end
  
  # INSTANCE METHODS
  
  test '#owner returns the commentable' do
    @comment.owner.should == @article
  end
  
  test '#filter returns the comment_filter attribute of the commentable' do
    mock(@comment.commentable.target).comment_filter.returns :filter
    @comment.filter.should == :filter
  end
  
  # approved?
  
  test '#approved? returns true if the approved attribute is not 0' do
    @comment.approved = 1
    @comment.approved?.should be_true
  end
  
  test '#approved? returns true if the approved attribute is 0' do
    @comment.approved = 0
    @comment.approved?.should be_false
  end
    
  # state_changes
  
  test "#state_changes returns :updated, :approved when the comment was just approved" do
    @comment.approved = 0
    @comment.clear_changes!
    @comment.approved = 1
    @comment.state_changes.should == [:updated, :approved]
  end
  
  test "#state_changes returns :updated, :unapproved when the comment was just unapproved" do
    @comment.approved = 1
    @comment.clear_changes!
    @comment.approved = 0
    @comment.state_changes.should == [:updated, :unapproved]
  end
  
  # authorize_commenting
  
  test '#authorize_commenting checks if the commentable accepts comments' do
    mock(@comment.commentable.target).accept_comments?.returns true
    @comment.send :authorize_commenting
  end
  
  test '#authorize_commenting raises CommentNotAllowed if the commentable does not accept comments' do
    mock(@comment.commentable.target).accept_comments?.returns false
    lambda{ @comment.send :authorize_commenting }.should raise_error
  end
  
  # set_owners
  
  test '#set_owners sets site and section from the commentable' do
    @comment.site, @comment.section = nil, nil
    @comment.send :set_owners
    @comment.site.should == @comment.commentable.site
    @comment.section.should == @comment.commentable.section
  end
  
  # update_commentable
  
  test '#update_commentable calls #after_comment_update on the commentable' do
    mock(@comment.commentable.target).after_comment_update(@comment)
    @comment.send :update_commentable
  end
  
  # author_link
  
  test "#author_link returns a link when author_url is present" do
    stub(@comment).author_homepage.returns 'http://somewhere.com'
    @comment.author_link.should == %(<a href="http://somewhere.com">#{@comment.author.name}</a>)
  end
  
  test "#author_link returns author_name when author_url is not present" do
    stub(@comment).author_homepage.returns nil
    @comment.author_link.should == @comment.author.name
  end
  
  # comment creation
  
  test "raises Comment::CommentNotAllowed when commentable.accept_comments? returns false" do
    mock(@article).accept_comments?.returns(false)
    comment = Comment.new :body => 'body', :author => User.first, :commentable => @article 
    lambda{ comment.save! }.should raise_error(Comment::CommentNotAllowed)
  end
  
  # filtering
  
  test "it does not allow html in the comment body" do
    @article.site.comment_filter = 'textile_filter'
    html = 'p{position:absolute; top:50px; left:10px; width:150px; height:150px}. secure html'
    @comment = Comment.new :body => html, :commentable => @article
    @comment.save(false)
    @comment.body_html.should == %(<p>secure html</p>)
  end
end

class CommentSpamControlTest < ActiveSupport::TestCase
  def setup
    super
    @section = Section.first
    @article = @section.articles.first
    @comment = @article.comments.first
    
    @engine = @section.spam_engine
    @report = SpamReport.new :engine => 'name', :spaminess => 0, 
                             :data => {:spam => false, :spaminess => 0, :signature => 'signature'}
    @context = {:url => 'http://www.domain.org/an-article'}
    
    stub(@engine).check_comment(@comment, @context).returns(@report)
  end

  test "#check_approval gets a spam_engine from the section" do
    mock(@comment.section.target).spam_engine.returns @engine
    @comment.check_approval @context
  end

  test "#check_approval gets a spam report from calling #check_comment on the spam engine" do
    mock(@comment.section.spam_engine).check_comment(@comment, @context).returns @report
    @comment.check_approval @context
  end
  
  test "#check_approval calculates the comment's spaminess from its spam_reports" do
    mock(@comment).calculate_spaminess.returns 999
    @comment.check_approval @context
    @comment.spaminess.should == 999
  end
  
  test "#check_approval sets the comment approved if it is ham" do
    mock(@comment).ham?.returns true
    @comment.check_approval @context
    @comment.approved?.should be_true
  end
  
  test "#check_approval saves the comment" do
    mock(@comment).save!
    @comment.check_approval @context
  end
end
