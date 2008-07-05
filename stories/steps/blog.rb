factories :sections, :articles

steps_for :blog do
  Given "a blog" do
    @blog = create_blog
  end

  Given "the blog allows anonymous users to create comments" do
    raise "this step expects @blog to be set" unless @blog
    @blog.permissions = {:comment => {:anonymous => :create}}
  end
  
  Given "a blog that allows anonymous users to create comments" do
    Given "a blog"
    Given "the blog allows anonymous users to create comments"
  end

  Given "a blog with no articles" do
    Given "a blog"
    @blog.articles.should be_empty
  end

  Given "a blog with an article" do
    @article = create_article
    @blog = @article.section
    @blog.articles.should have(1).record
  end

  When "the user visits the blog articles list page" do
    get admin_articles_path(@blog.site, @blog)
  end
end  
