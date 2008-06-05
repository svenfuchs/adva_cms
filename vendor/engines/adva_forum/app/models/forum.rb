class Forum < Section
  acts_as_commentable
  self.default_required_roles = { :manage_topics => :admin, 
                                  :manage_comments => :user }

  # attr_readonly :posts_count, :topics_count

  has_many :topics, :order => "topics.sticky desc, topics.last_updated_at desc", 
                    :dependent => :delete_all, :foreign_key => :section_id

  # this is used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many :recent_topics, :class_name => 'Topic', 
                           :include => [:profile],
                           :order => "topics.last_updated_at DESC",
                           :conditions => ["profiles.state == ?", "active"], 
                           :foreign_key => :section_id
                           
  has_one  :recent_topic,  :class_name => 'Topic', 
                           :order => "topics.last_updated_at DESC", 
                           :foreign_key => :section_id

  has_one  :recent_post,   :as => :commentable, 
                           :class_name => 'Comment', 
                           :order => "comments.created_at DESC"

  # TODO there's already a comments association from acts_as_commentable
  # can we remove this on?
  has_many :posts,       :order => "comments.created_at DESC", :as => :commentable, :class_name => 'Comment', :dependent => :delete_all
  
  
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
