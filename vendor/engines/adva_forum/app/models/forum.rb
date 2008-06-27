class Forum < Section
  acts_as_commentable

  permissions :topic   => { :user => [:create, :update], :moderator => [:destroy, :moderate] },
              :comment => { :user => :create, :author => [:update, :destroy] }

  has_option :topics_per_page, :default => 25
  has_option :comments_per_page, :default => 25    

  has_counter :topics, :comments, :as => :section

  has_many :topics,         :order => "topics.sticky desc, topics.last_updated_at desc",
                            :foreign_key => :section_id,
                            :dependent => :delete_all

  has_one  :recent_topic,   :class_name => 'Topic', 
                            :order => "topics.last_updated_at DESC", 
                            :foreign_key => :section_id

  has_one  :recent_comment, :class_name => 'Comment', 
                            :order => "comments.created_at DESC", 
                            :foreign_key => :section_id


  validates_numericality_of :topics_per_page, :only_integer => true, :message => "can only be whole number."
  # TODO validates_inclusion_of :topics_per_page, :in => 1..30, :message => "can only be between 1 and 30."  

  validates_numericality_of :comments_per_page, :only_integer => true, :message => "can only be whole number."
  # TODO validates_inclusion_of :comments_per_page, :in => 1..30, :message => "can only be between 1 and 30."  

end
