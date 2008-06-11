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

  has_one  :recent_comment, :class_name => 'Comment', 
                            :order => "comments.created_at DESC", 
                            :foreign_key => :section_id


  has_counter :topics, :comments, :as => :section
end
