factories :forum

steps_for :forum do
  Given 'a forum' do
    @forum ||= begin
      Given 'a site'
      Section.delete_all
      create_forum :site => @site
    end
  end

  Given "a forum that allows registered users to post comments" do
    Given "a forum"
    @forum.update_attributes! 'permissions' => {
      'topic'   => {'show' => 'anonymous', 'create' => 'user'},
      'comment' => {'show' => 'anonymous', 'create' => 'user'}
    }
  end
  
  Given "a forum that allows anonymous users to post comments" do
    Given "a forum"
    @forum.update_attributes! 'permissions' => {
      'topic'   => {'show' => 'anonymous', 'create' => 'anonymous'},
      'comment' => {'show' => 'anonymous', 'create' => 'anonymous'}
    }
  end
  
  Given "the forum has no boards" do
    Board.delete_all
    Topic.delete_all
    Comment.delete_all
  end
  
  Given "the forum has a board" do
    Board.delete_all
    Topic.delete_all
    Comment.delete_all
    @board = create_board :section => @forum
  end
  
  When "the user goes to the forum page" do
    get forum_path(@forum)
  end
  
  When "the user goes to the board page" do
    get forum_board_path(@forum, @board)
  end
  
  Then "the page shows an empty list of topics" do
    response.should have_tag('#topics.empty')
  end
  
  Then "the page has a topic creation form" do
    response.should have_form_posting_to('/topics')
  end
  
  Then "the page has a post creation form" do
    response.should have_form_posting_to("/topics/#{@topic.id}/posts")
  end
  
  When "the user fills in the topic creation form with valid values" do
    fills_in 'title', :with => 'the topic title'
    fills_in 'body', :with => 'the initial comment body'
  end
  
  When "the user fills in the topic creation form with name, email and valid topic values" do
    fills_in 'name', :with => 'anonymous'
    fills_in 'e-mail', :with => 'anonymous@email.com'
    fills_in 'title', :with => 'the topic title'
    fills_in 'body', :with => 'the initial comment body'
  end
  
  When "the user fills in the post creation form with valid values" do
    fills_in 'post[body]', :with => 'the reply body'
  end
  
  When "the user fills in the post creation form with name, email and valid topic values" do
    fills_in 'name', :with => 'anonymous'
    fills_in 'e-mail', :with => 'anonymous@email.com'
    fills_in 'post[body]', :with => 'the reply body'
  end
  
  Then "the new topic is created" do
    @topic = Topic.find :first
    @topic.should_not be_nil
    @topic.title.should == 'the topic title'
  end
  
  Then "the initial topic comment is created" do
    @topic.comments.count.should == 1
    @comment = @topic.comments.first
    @comment.body.should == 'the initial comment body'
  end
  
  Then "the new reply is created" do
    @topic.reload
    @topic.comments(true).count.should == 2
    @reply = @topic.comments.last
    @reply.should_not be_nil
    @reply.body.should == 'the reply body'
  end
  
  Then "the user is redirected to the topic show page" do
    request.request_uri.should =~ %r(/topics/the-topic-title)
    response.should render_template("topics/show")
  end
end