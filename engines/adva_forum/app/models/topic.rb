class Topic < ActiveRecord::Base
  has_permalink :title
  has_many_comments :as => :commentable

  acts_as_role_context :parent => Section
  # acts_as_role_context :roles => :author, :implicit_roles => lambda{|user|
  #   comments.by_author(user).map{|comment| Role.build :author, comment }
  # }

  belongs_to :site
  belongs_to :section
  belongs_to :board
  belongs_to :last_comment, :class_name => 'Comment', :foreign_key => :last_comment_id

  belongs_to_author
  belongs_to_author :last_author, :validate => false

  before_validation :set_site

  validates_presence_of :section, :title
  validates_presence_of :body, :on => :create

  attr_accessor :body
  delegate :comment_filter, :to => :site

  class << self
    def post(author, attributes)
      topic = Topic.new attributes.merge(:author => author)
      topic.last_author = author
      # topic.last_author_email = author.email
      topic.reply author, :body => attributes[:body]
      # revise topic, attributes
      topic
    end
  end

  def owner
    board || section
  end

  def reply(author, attributes)
    returning comments.build(attributes) do |comment|
      comment.author = author
      comment.board = self.board
      comment.commentable = self
    end
  end
  
  def revise(author, attributes)
    #self.sticky, self.locked = attributes.delete(:sticky), attributes.delete(:locked) # if author.has_permission ...
    self.attributes = attributes
    return unless board_id_changed?
    comments.each do |comment|
      comment.update_attribute(:board_id, attributes[:board_id])
    end
  end

  # def hit!
  #   self.class.increment_counter :hits, id
  # end

  def accept_comments?
    !locked?
  end

  def paged?
    comments_count > @section.comments_per_page
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

  def after_comment_update_with_topic(comment)
    if comment = comment.frozen? ? comments.last_one : comment
      update_attributes! :last_updated_at => comment.created_at, :last_comment_id => comment.id, :last_author => comment.author
    else
      self.destroy
    end
  end
  alias_method_chain :after_comment_update, :topic
  
  def initial_post
    comments.first
  end
  
  protected
    def set_site
      self.site_id = section.site_id
    end
end