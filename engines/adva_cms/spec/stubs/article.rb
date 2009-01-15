define Article do
  has_many :comments, :build => stub_comment
  has_many [:approved_comments, :unapproved_comments], stub_comments
  has_many :categories
  has_many :tags
  has_one  :comments_counter, stub_counter

  belongs_to :site
  belongs_to :section
  belongs_to :author, stub_user

  methods  :id => 1,
           :type => 'Article',
           :title => 'An article',
           :permalink => 'an-article',
           :full_permalink => {:year => 2008, :month => 1, :day => 1, :permalink => 'an-article'},
           :excerpt => 'excerpt',
           :excerpt_html => 'excerpt html',
           :body => 'body',
           :body_html => 'body html',
           :tag_list => 'foo bar',
           :version => 1,
           :author= => nil, # TODO add this to Stubby
           :author_name => 'author_name',
           :author_email => 'author_email',
           :author_homepage => 'author_homepage',
           :author_link => 'author_link',
           :comment_filter => 'textile-filter',
           :comment_age => 0,
           :primary? => false,
           :accept_comments? => true,
           :has_excerpt? => true,
           :published_at => Time.now,
           :published? => true,
           :published_at? => true,
           :draft? => false,
           :filter => nil,
           :attributes= => nil,
           :valid? => true,
           :save => true,
           :save_without_revision => true,
           :update_attributes => true,
           :has_attribute? => true,
           :destroy => true,
           :save_version_on_create => nil,
           :increment_counter => nil,
           :decrement_counter => nil,
           :state => :published,
           :track_method_calls => nil

  instance :article
end
