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
    @comment.should be_approved
  end

  test '#approved? returns true if the approved attribute is 0' do
    @comment.approved = 0
    @comment.should_not be_approved
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
    mock(@comment.commentable.target).accept_comments?.returns(true)
    @comment.send(:authorize_commenting)
  end

  test '#authorize_commenting raises CommentNotAllowed if the commentable does not accept comments' do
    mock(@comment.commentable.target).accept_comments?.returns(false)
    lambda { @comment.send(:authorize_commenting) }.should raise_error
  end

  # set_owners

  test '#set_owners sets site and section from the commentable' do
    @comment.site, @comment.section = nil, nil
    @comment.send(:set_owners)
    @comment.site.should == @comment.commentable.site
    @comment.section.should == @comment.commentable.section
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
    comment = Comment.new(:body => 'body', :author => User.first, :commentable => @article)
    lambda { comment.save! }.should raise_error(Comment::CommentNotAllowed)
  end

  # filtering

  test "it does not allow html in the comment body" do
    @article.site.comment_filter = 'textile_filter'
    html = 'p{position:absolute; top:50px; left:10px; width:150px; height:150px}. secure html'
    @comment = Comment.new(:body => html, :commentable => @article)
    @comment.save(false)
    @comment.body_html.should == %(<p>secure html</p>)
  end
end
