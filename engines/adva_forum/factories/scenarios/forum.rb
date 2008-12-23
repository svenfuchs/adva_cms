Factory.define_scenario :forum_with_topics do
  @site         ||= Factory :site
  @user         ||= Factory :user
  
  @forum        = Factory :forum, :site => @site
  @topic        = Factory :topic, :section => @forum, :author => @user, :last_updated_at => 1.month.ago
  @recent_topic = Factory :topic, :section => @forum, :author => @user, :last_updated_at => Time.now
  @forum.topics << @topic
  @forum.topics << @recent_topic
end