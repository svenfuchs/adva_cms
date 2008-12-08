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

Factory.define_scenario :site_with_newsletter do
  factory_scenario :empty_site
  @newsletter ||= Factory :newsletter, :site => @site
end

Factory.define_scenario :site_with_newsletter_and_issue do
  factory_scenario :empty_site
  @newsletter ||= Factory :newsletter, :site => @site
  @issue ||= Factory :issue, :newsletter => @newsletter
end

Factory.define_scenario :site_with_newsletter_and_issue_and_subscription do
  factory_scenario :empty_site
  @newsletter ||= Factory :newsletter, :site => @site
  @issue ||= Factory :issue, :newsletter => @newsletter
  @subscription ||= Factory :subscription, :newsletter => @newsletter
end
