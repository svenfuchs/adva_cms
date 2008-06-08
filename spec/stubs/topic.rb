define Topic do
  belongs_to :site, stub_site
  belongs_to :section
  has_many   :comments
  
  methods    :sticky? => false,
             :locked? => false,
             :save => true,
             :destroy => true,
             :revise => true,
             :last_comment => stub_comment,
             :last_updated_at => Time.now(),
             :last_author_name => 'last_author_name'
             
  instance   :topic,
             :id => 1,
             :title => 'a topic',
             :permalink => 'a-topic'

end

scenario :topic do
  @topic = stub_topic
end