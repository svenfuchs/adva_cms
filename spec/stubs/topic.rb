define Topic do
  belongs_to :site, stub_site
  belongs_to :section
  has_many   :comments
  has_one    :last_comment, stub_comment
  has_one    :comments_counter, stub_counter
  
  methods    :sticky? => false,
             :locked? => false,
             :save => true,
             :destroy => true,
             :revise => true,
             :comments_count => 1,
             :last_page => 2,
             :last_comment => stub_comment,
             :last_updated_at => Time.now(),
             :last_author_name => 'last_author_name'
             
  instance   :topic,
             :id => 1,
             :title => 'a topic',
             :permalink => 'a-topic'

end