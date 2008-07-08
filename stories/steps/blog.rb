factories :sections, :articles

steps_for :blog do
  Given 'a blog' do
    @blog = create_blog
  end
  
  Given "a blog that allows anonymous users to create comments" do
    Given "a blog"
    @blog.update_attributes! 'permissions' => {'comment' => {'anonymous' => 'create'}}
  end
  
  Given 'a blog with no articles' do
    Article.delete_all
    @blog = create_blog
    @blog.articles.should be_empty
    @article_count = 0
  end

  Given "a blog with an article" do
    Article.delete_all
    @article = create_article
    @blog = @article.section
  end 
  
  Given "a blog with a category" do
    Category.delete_all
    Section.delete_all
    @blog = create_blog
    @category = create_category :section => @blog
  end

  Given "a blog with no categories" do
    Category.delete_all
    Section.delete_all
    @blog = create_blog
  end

  Given "a blog with no assets" do
    # Articles have the assets of blog
    Given "a blog with no articles"
  end
  
  Given 'a blog article' do
    Article.delete_all
    @article = create_article
    @article_count = 1
  end
  
  Given 'a published blog article' do
    Given 'a blog article'
    @article.update_attributes! :published_at => '2008-01-01 12:00:00'
  end
  
  Given 'an unpublished blog article' do
    Given 'a blog article'
  end
  
  Given 'a published blog article with no excerpt' do
    Given 'a published blog article'
    @article.update_attributes! :excerpt => '', :excerpt_html => ''
  end
end
