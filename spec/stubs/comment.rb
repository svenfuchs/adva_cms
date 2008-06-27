define Comment do
  belongs_to :author, stub_user
  
  methods  :id => 1,
           :body => 'body', 
           :body_html => 'body html',
           :author= => nil, # TODO add this to Stubby
           :author_name => 'author_name',
           :author_email => 'author_email',
           :author_homepage => 'author_homepage',
           :author_link => 'author_link',
           :created_at => Time.now,
           :approved? => true,
           :update_attributes => true,
           :save => true,
           :destroy => true,
           :has_attribute? => true,
           :frozen? => false

  instance :comment
end

scenario :comment do
  @comment = stub_comment
  @comments = stub_comments
  @comment.stub!(:commentable).and_return @article || @wikipage
  @comment.stub!(:commentable=)
end

scenario :three_comments do
  scenario :user, :site
  
  @forum = Forum.new :title => 'forum', :site => @site
  @forum.stub!(:build_path).and_return 'forum'
  @forum.save!
  
  @three_days_ago = 3.days.ago
  @two_days_ago = 2.days.ago
  @one_day_ago = 1.days.ago
  
  Time.stub!(:now).and_return @three_days_ago
  topic_attributes = {:title => 'topic title', :body => 'first comment', :last_author => stub_user, :last_author_name => 'name', :last_author_email => 'email@email.org', :section => @forum}
  @topic = Topic.post @user, topic_attributes
  @topic.save!
  
  Time.stub!(:now).and_return @two_days_ago
  @earlier_comment = @topic.reply @user, :body => 'second comment'
  @earlier_comment.save!

  Time.stub!(:now).and_return @one_day_ago
  @latest_comment = @topic.reply @user, :body => 'third comment'
  @latest_comment.save!
end

scenario :comment_exists do
  scenario :site, :section, :article, :user
  @comment = Comment.new :author => stub_user, :commentable => stub_article, :body => 'body'
  stub_methods @comment, :new_record? => false, :body_changed? => false
end

scenario :comment_created do
  scenario :comment_exists
  stub_methods @comment, :new_record? => true
end

scenario :comment_updated do
  scenario :comment_exists
  stub_methods @comment, :body_changed? => true
end

scenario :comment_approved do
  scenario :comment_exists
  stub_methods @comment, :approved? => true
  stub_methods @comment, :approved_changed? => true
end

scenario :comment_unapproved do
  scenario :comment_exists
  stub_methods @comment, :approved? => false
  stub_methods @comment, :approved_changed? => true
end

scenario :comment_destroyed do
  scenario :comment_exists
  stub_methods @comment, :frozen? => true
end
