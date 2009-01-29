require File.expand_path(File.dirname(__FILE__) + '/../../test_helper.rb')

class BoardTest < ActiveSupport::TestCase
  def setup
    super
    @forum = Forum.find_by_permalink 'a-forum-with-boards'
    @board = @forum.boards.first
    @topic = @board.topics.find_by_permalink('a-board-topic')
    forum_without_boards = Forum.find_by_permalink 'a-forum-without-boards'
    @topic = forum_without_boards.topics.first
  end
  
  test "acts as a commentable" do
    Board.should act_as_commentable
  end
  
  test "acts as role context with a Section as a parent" do
    Board.should act_as_role_context(:parent => Section)
  end

  test "has a topics counter" do
    Board.should have_counter(:topics)
  end
  
  test "delegates topics_per_page to the section" do
    @forum.update_attribute(:topics_per_page, 9)
    @board.topics_per_page.should == @forum.topics_per_page
  end
  
  test "delegates comments_per_page to the section" do
    @forum.update_attribute(:comments_per_page, 9)
    @board.comments_per_page.should == @forum.comments_per_page
  end
  
  # Associations
  
  test "belongs to a site" do
    @board.should belong_to(:site)
  end
  
  test "belongs to a section" do
    @board.should belong_to(:section)
  end
  
  test "has many topics" do
    @board.should have_many(:topics)
  end
  
  test "belongs to last_author" do
    @board.should belong_to(:last_author)
  end

  test "has one recent topic" do
    @board.should have_one(:recent_topic)
  end

  test "has one recent comment" do
    @board.should have_one(:recent_comment)
  end
  
  # FIXME make these things to work without stubbing
  
  test "#recent_topic returns the most recent topic" do
    @recent_topic = @board.topics.last
    stub(@recent_topic).last_updated_at.returns Time.now
    @board.recent_topic.should == @recent_topic
  end
  
  # FIXME make these things to work without stubbing
  
  test "#recent_comment returns the most recent comment" do
    @recent_comment = @board.comments.last
    stub(@recent_comment).last_updated_at.returns Time.now
    @board.recent_comment.should == @recent_comment
  end

  test "has a comments counter" do
    @board.should have_one(:comments_counter)
  end
  
  # Callbacks
  
  # test "initializes the topics counter after create" do
  #   Board.after_create.should include(:set_topics_count)
  # end
  # 
  # test "initializes the comments counter after create" do
  #   Board.after_create.should include(:set_comments_count)
  # end
  
  test "sets the site before validation" do
    Board.before_validation.should include(:set_site)
  end
  
  test "assigns any unassigned topics to self after create" do
    Board.after_create.should include(:assign_topics)
  end
  
  test "unassigns assigned board topics before destroying the last board" do
    Board.before_destroy.should include(:unassign_topics)
  end
  
  # Counters
  
  test "forum should have three boards" do
    @forum.boards.count.should == 3
  end

  test "should have two topics" do
    @board.topics.count.should == 2
  end

  test "should have two comments" do
    @board.comments.count.should == 2
  end

  test "should have counted the comments" do
    @board.comments_count.should == 2
  end

  test "should have counted the topics" do
    @board.topics_count.should == 2
  end
  
  # Cached attributes
  #
  # FIXME make these things to work without stubbing
  #
  # test "should have last_comment_id set" do
  #   @recent_comment = @board.comments.last
  #   stub(@recent_comment).last_updated_at.returns Time.now
  #   @board.last_comment_id.should == @recent_comment.id
  # end
  # 
  # test "should have last_updated_at set" do
  #   @board.last_updated_at.should == @board.created_at
  # end
  # 
  # test "should have last_author set" do
  #   @board.last_author.should == @user
  # end
  
  # Public methods
  
  # test '#after_comment_update, destroys itself if the comment was destroyed and no more comments exist' do
  #   @comment.stub!(:frozen?).and_return true
  #   @board.comments.stub!(:last_one).and_return nil
  #   @board.should_receive(:destroy)
  #   @board.after_comment_update(@comment)
  # end
  # 
  # test 'updates its cache attributes if the comment was saved' do
  #   @board.should_receive(:update_attributes!).with(@fields)
  #   @board.after_comment_update(@comment)
  # end
  # 
  # test 'updates its cache attributes if the comment was destroyed but more comments exist' do
  #   @comment.stub!(:frozen?).and_return true
  #   @board.comments.stub!(:last_one).and_return @comment
  #   @board.should_receive(:update_attributes!).with(@fields)
  #   @board.after_comment_update(@comment)
  # end
  
  test "#last?, returns true if forum has only one board" do
    @board = Board.find_by_title('a lone board')
    @board.last?.should be_true
  end
  
  test "#last?, returns false if forum has more than one board" do
    @board.last?.should be_false
  end
  
  # Protected methods
  
  # .author
  
  test "#author, returns section as owner of board" do
    @board.send(:owner).should == @board.section
  end
  
  # .set_site
    
  test "#set_site, sets the boards site from section.site" do
    @board = Board.new(:section => @forum)
    @board.send(:set_site)
    @board.site.should == @forum.site
  end
  
  test "#set_site, does not set the site for board if board does not have section" do
    @board = Board.new
    @board.send(:set_site)
    @board.site.should be_nil
  end
  
  # FIXME this looks more like a test for integration tests, which already exists
  #
  # test "#assign_topics, fetches all the boardless topics from forum" do
  #   @forum.should_receive(:boardless_topics).and_return [@topic]
  #   @board.send(:assign_topics)
  # end
  # 
  # test "assigns topic to the board" do
  #   @board.send(:assign_topics)
  #   @topic.reload
  #   @topic.board.should == @board
  # end
  # 
  # test "assigns topics comment(s) to the board" do
  #   @board.send(:assign_topics)
  #   @topic.reload
  #   @topic.initial_post.board.should == @board
  # end
  # 
  # FIXME this looks more like a test for integration tests, which already exists
  #
  # describe "#unassign_topics" do
  #   before :each do
  #     @topic = @forum.topics.post(@user, Factory.attributes_for(:topic, :section => @forum))
  #     @board.topics << @topic
  #     @board.save
  #     @topic.reload
  #   end
  #   
  #   it "unassigns topic to the board" do
  #     @board.stub!(:last?).and_return true
  #     @board.destroy
  #     @topic.board.should be_nil
  #   end
  #   
  #   it "unassigns topics comment(s) from the board" do
  #     @board.send(:assign_topics)
  #     @topic.reload
  #     @topic.initial_post.board.should be_nil
  #   end
end