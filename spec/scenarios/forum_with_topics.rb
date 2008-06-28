scenario :forum_with_topics do 
  scenario :empty_site

  @forum = stub_forum
  @topic = stub_topic
  @topics = stub_topics
  
  @site.sections.stub!(:find).and_return @forum

  Section.stub!(:find).and_return @forum
  Section.stub!(:paths).and_return ['section', 'blog', 'forum', 'wiki']
end