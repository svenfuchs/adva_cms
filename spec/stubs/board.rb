define Board do
  belongs_to :site
  belongs_to :section
  
  has_many :topics, :find_by_permalink => stub_topic,
                    :post => stub_topic
  has_one  :topics_counter, stub_counter
  has_one  :comments_counter, stub_counter

  methods  :id => 1,
           :title => 'board title', 
           :description => 'board description'
           :topics_per_page => 15,
           :comments_per_page => 15,
           :topics_count => stub_counter,
           :comments_count => stub_counter,
           :save => true,
           :update_attributes => true,
           :destroy => true

  instance :board
end
  
