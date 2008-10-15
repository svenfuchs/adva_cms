scenario :forum_with_topics do 
  scenario :empty_site

  @section = @forum = stub_forum
  @topic = stub_topic
  @topics = stub_topics
  
  @site.sections.stub!(:find).and_return @forum
  @site.sections.stub!(:root).and_return @forum

  Section.stub!(:find).and_return @forum
  Section.stub!(:paths).and_return ['section', 'blog', 'forum', 'wiki']

  counter = stub('approved_comments_counter', :increment! => true, :decrement! => true)
  @section.stub!(:approved_comments_counter).and_return counter
  @site.stub!(:approved_comments_counter).and_return counter
  

end