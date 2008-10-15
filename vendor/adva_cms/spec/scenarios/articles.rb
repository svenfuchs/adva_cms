scenario :blank_article do
  Article.delete_all
  @article = Article.new :author => stub_user,
                         :site_id => stub_site, :section_id => stub_section,
                         :title => 'An article',
                         :body => 'body'
end

scenario :article_exists do
  scenario :blank_article
  stub_methods @article, :new_record? => false, :save_version? => false
end

scenario :article_created do
  scenario :article_exists
  @article.id = nil
  stub_methods @article, :new_record? => true
end

scenario :article_revised do
  scenario :article_exists
  stub_methods @article, :save_version? => true
end

scenario :article_published do
  scenario :article_exists
  stub_methods @article, :published? => true
  stub_methods @article, :published_at_changed? => true
end

scenario :article_unpublished do
  scenario :article_exists
  stub_methods @article, :published? => false
  stub_methods @article, :published_at_changed? => true
end

scenario :article_destroyed do
  scenario :article_exists
  stub_methods @article, :frozen? => true
end

scenario :article_published_on_2008_1_1 do
  scenario :blank_article
  Article.delete_all
  @article.published_at = Time.zone.local 2008, 1, 1
  @article.save!
end

scenario :six_articles_published_in_three_months do
  Article.delete_all

  @site = Site.create! :host => 'host', :name => 'site', :title => 'title'
  @blog = Blog.create! :title => 'title', :site => @site

  1.upto(3) do |month|
    1.upto(month) do |day|
      Article.create :author => stub_user, :site => @site, :section => @blog,
                     :title => "Article on day #{day} in month #{month}", :body => 'body',
                     :published_at => Time.zone.local(2008, month, day)
    end
  end
end

