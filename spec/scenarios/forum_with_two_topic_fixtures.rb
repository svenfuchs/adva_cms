scenario :forum_with_two_topic_fixtures do
  @forum = Forum.new :site => stub_site, :title => 'forum'
  @forum.stub!(:build_path)
  @forum.save
  
  attributes = {:title => 'title', :body => 'body', :author => stub_user, :last_author => stub_user, :last_author_name => 'name', :section => @forum}
  @earlier_topic = Topic.create! attributes.update(:last_updated_at => 1.month.ago)
  @latest_topic = Topic.create! attributes.update(:last_updated_at => Time.now)
  
  @earlier_topic.stub!(:section).and_return @forum
  @latest_topic.stub!(:section).and_return @forum
end