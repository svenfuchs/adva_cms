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
end  
