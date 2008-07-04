factories :sections

steps_for :blog do
  Given "a blog" do
    @blog = create_blog
  end

  Given "the blog allows anonymous users to create comments" do
    @blog.permissions = {:comment => {:anonymous => :create}}
  end
  
  Given "a blog that allows anonymous users to create comments" do
    $rspec_story_steps[:blog].find(:given, "a blog").perform(self)
    $rspec_story_steps[:blog].find(:given, "the blog allows anonymous users to create comments").perform(self)
  end

  Given "a blog with no articles" do
    @blog = create_blog
    @blog.articles.should be_empty
  end

  When "the user visits the blog page" do
    get "/admin/sites/#{@blog.site.id}/sections/#{@blog.id}/articles"
  end

  When "the user clicks on '$link'" do |link|
    clicks_link link
  end
end  
