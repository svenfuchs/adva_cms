scenario :forum_with_three_comments do
  @forum = Forum.new :title => 'forum', :site => stub_site
  @forum.stub!(:build_path).and_return 'forum'
  @forum.save!

  counter = stub('approved_comments_counter', :increment! => true, :decrement! => true)
  @forum.stub!(:approved_comments_counter).and_return counter
  stub_site.stub!(:approved_comments_counter).and_return counter

  @three_days_ago = 3.days.ago
  @two_days_ago = 2.days.ago
  @one_day_ago = 1.days.ago

  Time.stub!(:now).and_return @three_days_ago
  topic_attributes = {:title => 'topic title', :body => 'first comment', :last_author => stub_user, :last_author_name => 'name', :section => @forum, :site => stub_site}
  @topic = Topic.post stub_user, topic_attributes
  @topic.save!

  Time.stub!(:now).and_return @two_days_ago
  @earlier_comment = @topic.reply stub_user, :body => 'second comment'
  @earlier_comment.save!

  Time.stub!(:now).and_return @one_day_ago
  @latest_comment = @topic.reply stub_user, :body => 'third comment'
  @latest_comment.save!
end