define Forum do
  belongs_to :site
  
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
           :render_options => {},
           :template => 'template',
           :layout => 'layout',
           :content_filter => 'textile-filter',
           :topics_per_page => 15,
           :comments_per_page => 15,
           :valid? => true,
           :has_attribute? => true,
           :topics_count => stub_counter,
           :comments_count => stub_counter

  instance :forum
end

scenario :forum do 
  @forum = stub_forum
  @topic = stub_topic
  @topics = stub_topics
  
  Section.stub!(:find).and_return @forum
  Section.stub!(:types).and_return ['Section', 'Blog', 'Wiki']
  Section.stub!(:paths).and_return ['section', 'blog', 'forum', 'wiki']
  
  # @site.stub_collection! :sections, @sections, [:find, :build, :root] => @blog if @site
end
  
