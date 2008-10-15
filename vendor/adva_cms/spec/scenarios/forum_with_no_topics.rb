scenario :forum_with_no_topics do
  scenario :empty_site

  @forum = @section = stub_forum
  @forum.stub!(:topics).and_return []

  @site.sections.stub!(:find).and_return @forum

  Section.stub!(:find).and_return @forum
  Section.stub!(:paths).and_return ['section', 'blog', 'forum', 'wiki']
end