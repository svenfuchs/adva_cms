define Blog do
  belongs_to :site

  has_many :articles, [:find, :find_published_by_permalink, :build, :primary] => stub_article,
                      [:roots, :paginate, :paginate_published_in_time_delta] => stub_articles,
                      :permalinks => ['an-article'], :maximum => 4
                      
  has_many :categories, [:find, :build, :root] => stub_category, 
                        [:paginate, :roots] => stub_categories
        
  has_many :comments, :build => stub_comment
  has_many [:approved_comments, :unapproved_comments], stub_comments

  methods  :id => 1,
           :type => 'Blog', 
           :path => 'blog',
           :title => 'blog title', 
           :permalink => 'blog',
           :comment_age => 0,
           :render_options => {},
           :template => 'template',
           :layout => 'layout',
           :content_filter => 'textile-filter',
           :archive_months => [],
           :valid? => true,
           :has_attribute? => true,
           :required_roles => { :manage_articles => :admin, :manage_categories => :admin },
           :required_role_for => :admin

  instance :blog
end

scenario :blog do 
  @blog = stub_blog
  
  Section.stub!(:find).and_return @blog
  Section.stub!(:types).and_return ['Section', 'Blog', 'Wiki']
  Section.stub!(:paths).and_return ['section', 'sections/section', 'blog', 'blogs/blog', 'wikis/wiki', 'wiki']
  
  # @site.stub_collection! :sections, @sections, [:find, :build, :root] => @blog if @site
end
  
