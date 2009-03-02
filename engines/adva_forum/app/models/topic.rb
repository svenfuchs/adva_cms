class Topic < ActiveRecord::Base
  # FIXME shouldn't this be scoped to topic and/or forum?
  has_permalink :title, :url_attribute => :permalink, :sync_url => true, :only_when_blank => true 
  before_destroy :decrement_counter
  has_many_posts :as => :commentable

  belongs_to :site
  belongs_to :section
  belongs_to :board
  belongs_to :last_post, :class_name => 'Comment', :foreign_key => :last_post_id
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
    returning posts.build(attributes) do |post| # FIXME should be posts.create ?
      post.author = author
      post.board = self.board
      post.topic = self
    end
  end
  
  def update_attributes(attributes)
    board_id = attributes.delete(:board_id)
    returning super do
      move_to_board(board_id) if board_id
    end
  end
  
  def move_to_board(board_id)
    # FIXME only move if the board_id actually different from self.board_id
    if board
      board.topics_counter.decrement!
      board.posts_counter.decrement_by!(posts_count)
    end
  
    update_attribute(:board_id, board_id)
    posts.each { |post| post.update_attribute(:board_id, board_id) } # FIXME how to bulk update this in one query?
    return unless board(true) # e.g. if board_id is set to nil

    board.topics_counter.increment!
    board.posts_counter.increment_by!(posts_count)
  end

  # def hit!
  #   self.class.increment_counter :hits, id
  # end

  def accept_comments?
    !locked?
  end

  def paged?
    posts_count > section.posts_per_page
  end
  
  def page(post)
    count = posts.count(:all, :conditions => ['id <= ?', post.id])
    [(count.to_f / section.posts_per_page.to_f).ceil.to_i, 1].max
  end

  def last_page
    @last_page ||= [(posts_count.to_f / section.posts_per_page.to_f).ceil.to_i, 1].max
  end

  def previous
    collection = board ? board.topics : section.topics
    collection.find :first, :conditions => ['last_updated_at < ? AND id < ?', last_updated_at, id], 
                            :order => "last_updated_at, id"
  end

  def next
    collection = board ? board.topics : section.topics
    collection.find :first, :conditions => ['last_updated_at > ? AND id > ?', last_updated_at, id],
                            :order => "last_updated_at, id"
  end
  
  def initial_post
    posts.first
  end

  # FIXME can we extract this to an observer or similar?
  def after_post_update(post)
    if post = post.frozen? ? posts.last : post
      update_attributes! :last_updated_at => post.created_at, 
                         :last_post_id => post.id, 
                         :last_author => post.author
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
      section.posts_counter.decrement_by!(posts_count)
      board.posts_counter.decrement_by!(posts_count) if board
    end
end