Factory.define_scenario :site_with_forum do
  @site   ||= Factory :site
  @forum  = Factory :forum, :site => @site
end

Factory.define_scenario :forum_with_topics do
  @site         ||= Factory :site
  @user         = Factory :user
  @forum        = Factory :forum, :site => @site
  attributes    = {:section => @forum, :author => @user, :last_author => @user}
  @topic        = Factory :topic, attributes.merge(:last_updated_at => 1.month.ago)
  @recent_topic = Factory :topic, attributes.merge(:last_updated_at => Time.now)
  
  @topic.comments          << Factory(:post, :author => attributes[:author], :commentable => @topic)
  @recent_topic.comments   << Factory(:post, :author => attributes[:author], :commentable => @recent_topic)
  @forum.topics         << @topic
  @forum.topics         << @recent_topic
end