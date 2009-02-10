class Board < ActiveRecord::Base
  acts_as_role_context :parent => Section
  has_counter :topics

  before_validation :set_site
  after_create      :assign_topics
  before_destroy    :unassign_topics, :decrement_counters # must happen before associations
                    
  belongs_to        :site
  belongs_to        :section
  belongs_to_author :last_author, :validate => false
  has_many          :topics, :foreign_key => :board_id, :dependent => :delete_all, 
                             :order => "topics.sticky desc, topics.last_updated_at desc"
  has_many_comments :class_name => 'Post' # must happen after before_destroy
  
  validates_presence_of :title
  
  delegate :topics_per_page, :comments_per_page, :to => :section

  # FIXME somehow remove the method_chain here. looks ugly.
  def after_comment_update_with_cache_attributes(comment)
    comment = comment.frozen? ? comments.last : comment
    update_attributes! :last_updated_at => (comment ? comment.created_at : nil), 
                       :last_comment_id => (comment ? comment.id : nil), 
                       :last_author     => (comment ? comment.author : nil)
    
    after_comment_update_without_cache_attributes(comment)
  end
  alias_method_chain :after_comment_update, :cache_attributes
  
  def last?
    owner.boards.size == 1
  end
  
  protected
    # Called when a board is created. When there are boardless topics they are moved to the board.
    # This is to protect the user from loosing topics that are already assigned to the forum when 
    # he creates a board.
    def assign_topics
      owner.boardless_topics.each do |topic|
        topics << topic
        topics_counter.increment!
        topic.comments.each do |comment|
          comment.update_attribute(:board, self)
          comments_counter.increment!
        end
      end
    end
    
    # Called when a board is deleted. When this is the last board the topics are moved to the forum.
    # This is so the user is able to revert the process of creating a board when there already are
    # topics on the forum.
    def unassign_topics
      return unless last?
      topics.each do |topic|
        topic.update_attribute(:board_id, nil)
        topic.comments.each do |comment|
          comment.update_attribute(:board_id, nil)
        end
      end
    end

    def decrement_counters
      return if last?
      section.topics_counter.decrement_by!(topics_count)
      section.comments_counter.decrement_by!(comments_count)
    end
    
    def owner
      section
    end

    def set_site
      self.site_id = section.site_id if section
    end
end