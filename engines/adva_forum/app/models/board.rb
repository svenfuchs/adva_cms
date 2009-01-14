class Board < ActiveRecord::Base
  has_counter :topics
  belongs_to_author :last_author, :validate => false
  acts_as_role_context :parent => Section

  delegate :topics_per_page, :comments_per_page, :to => :section

  before_validation :set_site
  after_create      :assign_topics
  before_destroy    :unassign_topics  # Needs to be here before associations, otherwise topics are deleted on last board
  has_many_comments                   # Needs to be here after before_destroy, otherwise topics posts are lost when last board is deleted

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
  
  def after_comment_update_with_board(comment)
    if comment = comment.frozen? ? comments.last_one : comment
      update_attributes! :last_updated_at => comment.created_at, :last_comment_id => comment.id, :last_author => comment.author
    else
      self.destroy
    end
  end
  alias_method_chain :after_comment_update, :board
  
  def last?
    owner.boards.size == 1
  end
  
  protected
    def assign_topics
      owner.boardless_topics.each do |topic|
        self.topics << topic
        topic.comments.each do |comment|
          comment.update_attribute(:board, self)
        end
      end
    end
  
    def unassign_topics
      return unless last?
      topics.each do |topic|
        topic.update_attribute(:board_id, nil)
        topic.comments.each do |comment|
          comment.update_attribute(:board_id, nil)
        end
      end
    end

    def owner
      section
    end

    def set_site
      self.site_id = section.site_id if section
    end
end