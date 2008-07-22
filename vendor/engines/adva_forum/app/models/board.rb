class Board < ActiveRecord::Base
  has_many_comments
  has_counter :topics
  belongs_to_author :last_author, :validate => false 
  
  delegate :topics_per_page, :comments_per_page, :to => :section
  
  belongs_to :site
  belongs_to :section

  has_many :topics,         :order => "topics.sticky desc, topics.last_updated_at desc",
                            :foreign_key => :board_id,
                            :dependent => :delete_all

  has_one  :recent_topic,   :class_name => 'Topic', 
                            :order => "topics.last_updated_at DESC", 
                            :foreign_key => :board_id
  
  has_one  :recent_comment, :class_name => 'Comment', 
                            :order => "comments.created_at DESC", 
                            :foreign_key => :board_id
  
  before_validation :set_site
  
  def after_comment_update_with_board(comment)
    if comment = comment.frozen? ? comments.last_one : comment
      update_attributes! :last_updated_at => comment.created_at, :last_comment_id => comment.id, :last_author => comment.author
    else
      self.destroy
    end
  end
  alias_method_chain :after_comment_update, :board
  
  protected
    
    def set_site
      self.site_id = section.site_id if section
    end
  
end