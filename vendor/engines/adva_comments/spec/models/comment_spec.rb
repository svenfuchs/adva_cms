require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  include Stubby, Matchers::ClassExtensions

  before :each do
    scenario :wiki_with_wikipages

    @comment = Comment.new :body => 'the body'
    @comment.site = @site
    @comment.section = @wiki
    @comment.author = stub_user
    @comment.commentable = @wikipage
    @comment.commentable_type = 'Wiki'
    @comment.commentable_id = @wikipage.id
  end

  describe 'class extensions:' do
    it 'acts as a role context for the author role' do
      Comment.should act_as_role_context(:roles => :author)
    end

    it 'sanitizes the body_html attribute' do
      Comment.should filter_attributes(:sanitize => :body_html)
    end

    it "filters the body column" do
      @comment.should filter_column(:body)
    end
  end

  describe 'associations:' do
    it "belongs to a site" do
      @comment.should belong_to(:site)
    end

    it "belongs to a section" do
      @comment.should belong_to(:section)
    end

    it "belongs to a commentable" do
      @comment.should belong_to(:commentable)
    end
  end

  describe 'validations:' do
    it "validates presence of author (through belongs_to_author)" do
      @comment.should validate_presence_of(:author)
    end

    it "validates presence of body" do
      @comment.should validate_presence_of(:body)
    end

    it "validates presence of commentable" do
      @comment.should validate_presence_of(:commentable)
    end
  end

  describe 'callbacks:' do
    it 'sets owners (site + section) before validation' do
      Comment.before_validation.should include(:set_owners)
    end

    it 'authorizes commenting before create' do
      Comment.before_create.should include(:authorize_commenting)
    end

    it 'updates the commentable after create' do
      Comment.after_save.should include(:update_commentable)
    end

    it 'updates the commentable after destroy' do
      Comment.after_destroy.should include(:update_commentable)
    end
  end

  describe 'instance methods:' do
    it '#owner returns the commentable' do
      @comment.stub!(:commentable).and_return(@wikipage)
      @comment.owner.should == @wikipage
    end

    it '#filter returns the comment_filter attribute of the commentable' do
      @comment.commentable.should_receive(:comment_filter)
      @comment.filter
    end

    describe '#approved?' do
      it 'returns true if the approved attribute is not 0' do
        @comment.approved = 1
        @comment.approved?.should be_true
      end

      it 'returns true if the approved attribute is 0' do
        @comment.approved = 0
        @comment.approved?.should be_false
      end
    end
    
    describe '#state_changes' do
      it "returns :updated, :approved when the comment was just approved" do
        @comment.approved = 1
        @comment.state_changes.should == [:updated, :approved]
      end
      
      it "returns :updated, :unapproved when the comment was just unapproved" do
        @comment.approved = 1
        @comment.clear_changes!
        @comment.approved = 0
        @comment.state_changes.should == [:updated, :unapproved]
      end
    end

    describe '#authorize_commenting' do
      it 'it checks if the commentable accepts comments' do
        @comment.commentable.should_receive(:accept_comments?).and_return true
        @comment.send :authorize_commenting
      end

      it 'it raises CommentNotAllowed if the commentable does not accept comments' do
        @comment.commentable.stub!(:accept_comments?).and_return false
        lambda{ @comment.send :authorize_commenting }.should raise_error
      end
    end

    describe '#set_owners' do
      it 'sets site from the commentable' do
        @comment.commentable.should_receive(:site)
        @comment.should_receive(:site=)
        @comment.send :set_owners
      end

      it 'sets section from the commentable' do
        @comment.commentable.should_receive(:section)
        @comment.should_receive(:section=)
        @comment.send :set_owners
      end
    end

    it '#update_commentable calls #after_comment_update on the commentable' do
      @comment.commentable.should_receive(:after_comment_update)
      @comment.send :update_commentable
    end
  end

  it "returns a link as author_link when author_url is present" do
    @comment.stub!(:author_homepage).and_return 'http://somewhere.com'
    @comment.author_link.should == '<a href="http://somewhere.com">John Doe</a>'
  end

  it "returns author_name as author_link when author_url is not present" do
    @comment.stub!(:author_homepage).and_return nil
    @comment.author_link.should == 'John Doe'
  end

  it "calls commentable.accept_comments? before creating a comment" do
    @wikipage.should_receive(:accept_comments?).and_return(false)
    lambda { @comment.save! }.should raise_error
  end

  it "raises Comment::CommentNotAllowed when commentable.accept_comments? returns false before creating a comment" do
    @wikipage.stub!(:accept_comments?).and_return(false)
    lambda { @comment.save! }.should raise_error(Comment::CommentNotAllowed)
  end
end

describe Comment, "filtering" do
  it "it does not allow using insecure html in the comment body" do
    @comment = Comment.new :body => 'p{position:absolute; top:50px; left:10px; width:150px; height:150px}. secure html'
    @comment.should_receive(:filter).any_number_of_times.and_return 'textile_filter'
    @comment.save(false)
    @comment.body_html.should == %(<p>secure html</p>)
  end
end

describe Comment, "spam control" do
  before :each do
    @report = SpamReport.new(:engine => name, :spaminess => 0, :data => {:spam => false, :spaminess => 0, :signature => 'signature'})
    @spam_engine = stub('spam_engine', :check_comment => @report)
    @section = stub('section', :spam_engine => @spam_engine)

    @comment = Comment.new
    @comment.stub!(:section).and_return @section
    @comment.stub!(:save!)
    @context = {:url => 'http://www.domain.org/an-article'}
  end

  describe "#check_approval" do
    it "gets a spam_engine from the section" do
      @section.should_receive(:spam_engine).and_return @spam_engine
      @comment.check_approval @context
    end

    it "gets a spam report from calling #check_comment on the spam engine" do
      @spam_engine.should_receive(:check_comment).with(@comment, @context).and_return @report
      @comment.check_approval @context
    end

    it "calculates its spaminess from its spam_reports" do
      @comment.should_receive(:calculate_spaminess).and_return 999
      @comment.check_approval @context
      @comment.spaminess.should == 999
    end

    it "sets itself approved if it is ham" do
      @comment.should_receive(:ham?).and_return true
      @comment.check_approval @context
      @comment.approved?.should be_true
    end

    it "saves itself" do
      @comment.should_receive(:save!)
      @comment.check_approval @context
    end
  end
end
