factories :sections, :articles

steps_for :blog do
  Given "a blog" do
    @blog = create_blog
  end
end  
