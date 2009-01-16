define Blog do
  belongs_to :site

  has_many :articles, [:find, :find_by_permalink, :find_published_by_permalink, :build, :primary] => stub_article,
                      [:roots, :paginate, :paginate_published_in_time_delta] => stub_articles,
                      :permalinks => ['an-article'], :maximum => 4

  has_many :categories, [:find, :build, :root, :find_by_path] => stub_category,
                        [:paginate, :roots] => stub_categories

  has_many :comments, :build => stub_comment
  has_many [:approved_comments, :unapproved_comments], stub_comments
  has_one  :comments_counter, stub_counter

  methods  :id => 1,
           :type => 'Blog',
           :path => 'blog',
           :title => 'blog title',
           :permalink => 'blog',
           :comment_age => 0,
           :render_options => {:template => nil, :layout => nil},
           :template => 'template',
           :layout => 'layout',
           :content_filter => 'textile-filter',
           :archive_months => [],
           :valid? => true,
           :has_attribute? => true,
           :children => [],
           :track_method_calls => nil

  instance :blog

  instance :blogs_blog,
           :path => 'blogs/blog'
end
