class Forum < Section
  acts_as_commentable

  permissions :topic   => { :user => [:create, :update], :moderator => [:delete, :moderate] },
              :comment => { :user => :create, :author => [:update, :delete] }

  has_many :topics,         :order => "topics.sticky desc, topics.last_updated_at desc",
                            :foreign_key => :section_id,
                            :dependent => :delete_all

  has_one  :recent_topic,   :class_name => 'Topic', 
                            :order => "topics.last_updated_at DESC", 
                            :foreign_key => :section_id

  has_one  :recent_comment, :as => :commentable, 
                            # :class_name => 'Comment', 
                            :order => "comments.created_at DESC"


  # ummmm ... why did i invent this in the first place? for some reason 
  # counter_cache didn't work, but i can't remember it. *cough*

  # TODO abstract all of this to something like 
  # :has_counter :topics_count, :comments_count
  has_one :topics_count, :as => :owner, :class_name => 'Counter', :conditions => "name = 'topics'", :dependent => :delete
  has_one :comments_count, :as => :owner, :class_name => 'Counter', :conditions => "name = 'comments'", :dependent => :delete
  
  after_create :set_topics_count
  after_create :set_comments_count
  
  def set_topics_count
    Counter.create!(:owner => self, :name => 'topics')
  end
  
  def set_comments_count
    Counter.create!(:owner => self, :name => 'comments')
  end

  def after_topic_update(topic)
    topics_count.set topics.count 
    comments_count.set comments.count 
  end

end
