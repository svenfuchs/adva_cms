class Topic < ActiveRecord::Base
  # FIXME shouldn't this be scoped to topic and/or forum?
  has_permalink :title, :url_attribute => :permalink, :sync_url => true, :only_when_blank => true 
  before_destroy :decrement_counter
  has_many_comments :as => :commentable, :class_name => 'Post'

  belongs_to :site
  belongs_to :section
  belongs_to :board
  belongs_to :last_comment, :class_name => 'Comment', :foreign_key => :last_comment_id
  has_many :activities, :as => :object # move to adva_activity?

  belongs_to_author
  belongs_to_author :last_author, :validate => false

  before_validation :set_section, :set_site
  validates_presence_of :section, :title
  validates_presence_of :body, :on => :create

  attr_accessor :body
  delegate :comment_filter, :to => :site

  class << self
    def post(author, attributes)
      topic = Topic.new attributes.merge(:author => author)
      topic.last_author = author
      topic.reply author, :body => attributes[:body]
      topic.save
      return topic
    end
  end

  def owner
    board || section
  end

  def reply(author, attributes)
    returning comments.build(attributes) do |post| # FIXME should be comments.create ?
      post.author = author
      post.board = self.board
      post.commentable = self
    end
  end
  
  # FIXME why not just overwrite update_attributes here and call super?
  def revise(attributes)
    # self.sticky, self.locked = attributes.delete(:sticky), attributes.delete(:locked)
    board_id = attributes.delete(:board_id)
    if result = update_attributes(attributes)
      move_to_board(board_id) if board_id
    end
    result
  end
  
  def move_to_board(board_id)
    # FIXME only move if the board_id actually different from self.board_id
    if board
      board.topics_counter.decrement!
      board.comments_counter.decrement_by!(comments_count)
    end
  
    update_attribute(:board_id, board_id)
    comments.each { |comment| comment.update_attribute(:board_id, board_id) } # FIXME how to bulk update this in one query?
    return unless board(true) # e.g. if board_id is set to nil

    board.topics_counter.increment!
    board.comments_counter.increment_by!(comments_count)
  end

  # def hit!
  #   self.class.increment_counter :hits, id
  # end

  def accept_comments?
    !locked?
  end

  def paged?
    comments_count > section.comments_per_page
  end

  def last_page
    @last_page ||= [(comments_count.to_f / section.comments_per_page.to_f).ceil.to_i, 1].max
  end

  def previous
    collection = board ? board.topics : section.topics
    collection.find :first, :conditions => ['last_updated_at < ?', last_updated_at], :order => :last_updated_at
  end

  def next
    collection = board ? board.topics : section.topics
    collection.find :first, :conditions => ['last_updated_at > ?', last_updated_at], :order => :last_updated_at
  end
  
  def initial_post
    comments.first
  end

  # FIXME can we extract this to an observer or similar?
  def after_comment_update(comment)
    if comment = comment.frozen? ? comments.last : comment
      update_attributes! :last_updated_at => comment.created_at, 
                         :last_comment_id => comment.id, 
                         :last_author => comment.author
    else
      self.destroy
    end
  end
  
  protected
    def set_site
      self.site_id = section.site_id if section
    end
  
    def set_section
      self.section_id = board.section_id if board
    end
    
    def decrement_counter
      section.comments_counter.decrement_by!(comments_count)
      board.comments_counter.decrement_by!(comments_count) if board
    end
end