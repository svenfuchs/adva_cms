define Section do
  belongs_to :site

  has_many :articles,   [:find, :find_by_permalink, :find_published_by_permalink, :build, :primary] => stub_article,
                        [:roots, :paginate, :paginate_published_in_time_delta] => stub_articles,
                         :permalinks => ['an-article'], :maximum => 4

  has_many :categories, [:find, :build, :root, :find_by_path] => stub_category,
                        [:paginate, :roots] => stub_categories

  has_many :comments, :build => stub_comment
  has_many [:approved_comments, :unapproved_comments], stub_comments
  has_one  :comments_counter, stub_counter

  methods  :id => 1,
           :type => 'Section',
           :path => 'section',
           :permalink => 'section',
           :title => 'section title',
           :render_options => {},
           :template => 'template',
           :layout => 'layout',
           :content_filter => 'textile-filter',
           :comment_age => 0,
           :articles_per_page => 15,
           :accept_comments? => true,
           :valid? => true,
           :save => true,
           :update_attributes => true,
           :destroy => true,
           :has_attribute? => true

  instance :section
end