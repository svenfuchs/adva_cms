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

  When "the user clears the topic title" do
    fills_in 'title', :with => ''
  end

  When "the user fills in a different topic title" do
    fills_in 'title', :with => 'the updated topic title'
  end

  When "the user fills in the post creation form with valid values" do
    fills_in 'post[body]', :with => 'the post body'
  end

  When "the user fills in the post creation form with name, email and valid post values" do
    fills_in 'name', :with => 'anonymous'
    fills_in 'e-mail', :with => 'anonymous@email.com'
    fills_in 'post[body]', :with => 'the post body'
  end

  When "the user fills in the post creation form with only a name and a post body" do
    fills_in 'name', :with => 'anonymous'
    fills_in 'post[body]', :with => 'the post body'
  end

  When "the user fills in the post creation form with an email" do
    fills_in 'e-mail', :with => 'anonymous@email.com'
  end

  When "the user clears the post body from the post edit form" do
    fills_in 'post[body]', :with => ''
  end

  When "the user fills in the post edit form with a post body" do
    fills_in 'post[body]', :with => 'the updated body'
  end

  When "the user clicks on the topic's edit link" do
    link = find_link 'edit', ".meta span.anonymous-#{controller.current_user.id}"
    link.click
  end

  When "the user clicks on the post's edit link" do
    link = find_link 'edit', ".entry span.anonymous-#{controller.current_user.id}"
    link.click
  end

  Then "the page shows an empty list of topics" do
    response.should have_tag('#topics.empty')
  end

  Then "the page has a topic creation form" do
    response.should have_form_posting_to('/topics')
  end

  Then "the page has a topic edit form" do
    response.should have_form_putting_to("/topics/#{@topic.id}")
  end

  Then "the page has a post creation form" do
    response.should have_form_posting_to("/topics/#{@topic.id}/posts")
    @post_count = Post.count
  end

  Then "the page has a post edit form" do
    response.should have_form_putting_to("/topics/#{@topic.id}/posts/#{@post.id}")
  end

  Then "the page has an edit link for the topic that is visible for the anonymous user" do
    response.should have_tag('span[class*=?]', "anonymous-#{controller.current_user.id}") do |span|
      span.should have_tag('a[href^=?]', "/topics/#{@topic.permalink}/edit")
    end
  end

  Then "the page has an edit link for the post that is visible for the anonymous user" do
    response.should have_tag('span[class*=?]', "anonymous-#{controller.current_user.id}") do |span|
      span.should have_tag('a[href^=?]', "/topics/#{@topic.id}/posts/#{@post.id}/edit")
    end
  end

  Then "the new topic is created" do
    @topic = Topic.find :first
    @topic.should_not be_nil
    @topic.title.should == 'the topic title'
  end

  Then "the initial topic comment is created" do
    @topic.comments.count.should == 1
    @post = @topic.comments.first
    @post.body.should == 'the initial comment body'
  end

  Then "the topic is updated" do
    @topic.reload
    @topic.title.should == 'the updated topic title'
  end

  Then "the topic is not updated" do
    @topic.reload
    @topic.title.should_not be_blank
  end

  Then "the new post is created" do
    @topic.reload
    @topic.comments(true).count.should == 2
    @post = @topic.comments.last
    @post.should_not be_nil
    @post.body.should == 'the post body'
  end

  Then "no post is created" do
    @post_count.should == Post.count
  end

  Then "the post is not updated" do
    @post.reload
    @post.body.should_not be_blank
  end

  Then "the post is updated" do
    @post.reload
    @post.body.should == 'the updated body'
  end

  Then "the post creation form fields contain the posted values" do
    response.should have_tag('input[name=?][value=?]', 'anonymous[name]', 'anonymous')
    response.should have_tag('textarea[name=?]', 'post[body]', 'the post body')
  end

  Then "the user is redirected to the topic show page" do
    request.request_uri.should =~ %r(/topics/the-topic-title)
    response.should render_template("topics/show")
  end
end
