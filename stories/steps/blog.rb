factories :sections, :articles

steps_for :blog do
  Given "a blog" do
    @blog = create_blog
  end

  Given "the blog allows anonymous users to create comments" do
    @blog.permissions = {:comment => {:anonymous => :create}}
  end
  
  Given "a blog that allows anonymous users to create comments" do
    Given "a blog"
    Given "the blog allows anonymous users to create comments"
  end

  Given "a blog has no articles" do
    Given "a blog"
    @blog.articles.should be_empty
  end

  Given "a blog has an article"

  When "the user visits the blog page" do
    get admin_articles_path(@blog.site, @blog)
  end
end  
