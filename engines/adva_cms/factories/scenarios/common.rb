Factory.define_scenario :empty_site do
  @site ||= Factory.create :site
end

Factory.define_scenario :site_with_a_section do
  factory_scenario :empty_site
  @section ||= Factory :blog, :site => @site
end

Factory.define_scenario :site_with_a_blog do
  factory_scenario :empty_site
  @section ||= Factory :blog, :site => @site
end

Factory.define_scenario :site_with_a_wiki do
  factory_scenario :empty_site
  @section ||= Factory :wiki, :site => @site
end

Factory.define_scenario :site_with_calendar do
  factory_scenario :empty_site
  @section ||= Factory :calendar, :site => @site
end

Factory.define_scenario :site_with_location do
  factory_scenario :empty_site
  @location ||= Factory :location, :site => @site
end

Factory.define_scenario :calendar_with_event do
  factory_scenario :site_with_calendar
  @event ||= Factory :calendar_event, :section => @section
end

Factory.define_scenario :published_blog_article do
  factory_scenario :site_with_a_blog
  @article ||= Factory :published_blog_article, :site => @site, :section => @section
end

Factory.define_scenario :unpublished_blog_article do
  factory_scenario :site_with_a_blog
  @article ||= Factory :unpublished_blog_article, :site => @site, :section => @section
end

Factory.define_scenario :approved_article_comment do
  raise "@article not set" unless @article
  @comment = Factory :approved_comment, :commentable => @article, :author => @article.author
end

Factory.define_scenario :unapproved_article_comment do
  raise "@article not set" unless @article
  @comment = Factory :unapproved_comment, :commentable => @article, :author => @article.author
end

Factory.define_scenario :home_wikipage_with_revision do
  raise "@section not set" unless @section
  @wikipage ||= returning Factory(:wikipage, :site => @site, :section => @section) do |wikipage|
    wikipage.update_attributes! :body => "#{wikipage.body} (updated)"
  end
end

Factory.define_scenario :forum_with_board do
  @site   ||= Factory :site
  @forum  = Factory :forum, :site => @site
  @board  = Factory :board, :section => @forum
end

Factory.define_scenario :site_with_two_users do
  @site ||= Factory :site
  @membership = Factory :membership, :site => @site
  @other_membership = Factory :other_membership, :site => @site
end
