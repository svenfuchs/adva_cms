define Forum do
  belongs_to :site

  has_many :boards, :find => stub_board,
                    :build => stub_board
  has_many :topics, :find_by_permalink => stub_topic,
                    :post => stub_topic
  has_one  :topics_counter, stub_counter
  has_one  :comments_counter, stub_counter

  methods  :id => 1,
           :type => 'Forum',
           :path => 'forum',
           :title => 'forum title',
           :permalink => 'forum',
           :comment_age => 0,
           :render_options => {:template => nil, :layout => nil},
           :template => 'template',
           :layout => 'layout',
           :content_filter => 'textile-filter',
           :topics_per_page => 15,
           :comments_per_page => 15,
           :valid? => true,
           :has_attribute? => true,
           :topics_count => 0,
           :comments_count => 0,
           :track_method_calls => nil

  instance :forum
end

