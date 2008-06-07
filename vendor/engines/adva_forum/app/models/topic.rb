class Topic < ActiveRecord::Base
  has_permalink :title
  acts_as_commentable :polymorphic => true

  acts_as_role_context :implicit_roles => lambda{|user|
    posts.by_author(user).map{|post| Role.build :author, post }
  }

  belongs_to :section 
  belongs_to_author :last_author 
  
  has_many :posts, :as => :commentable, :order => "#{Post.table_name}.created_at", :class_name => 'Post', :dependent => :delete_all do
    def by_author(user)
      find_all_by_author_id_and_author_type(user.id, user.class.name)
    end
  end

  belongs_to :last_post, :class_name => 'Post', :foreign_key => :last_comment_id
  has_one    :recent_post, :as => :commentable, :order => "#{Post.table_name}.created_at DESC", :class_name => "Post"  

  validates_presence_of :section_id, :title # :profile_id, :forum_id?
  validates_presence_of :body, :on => :create

  attr_accessor :body
  # attr_readonly :posts_count, :hits
  
  delegate :comment_filter, :to => :site
  delegate :site, :to => :section

  before_validation :set_site
  
  # no need to call on after_create because that's already done by the post :o
  after_destroy :update_forum # TODO this would be defined in belongs_to :section, :counter_cache => true

  class << self
    def post(author, attributes)
      topic = Topic.new(attributes) do |topic|
        topic.last_author = author
        topic.reply author, :body => attributes[:body]
        # revise topic, attributes
      end
    end
  end
  
  def owner
    section
  end
    
  def reply(author, attributes)
    returning posts.build(attributes) do |post|
      post.author = author
      post.commentable = self
    end
  end
  
  def revise(author, attributes)
    self.sticky, self.locked = attributes.delete(:sticky), attributes.delete(:locked) # if author.has_permission ...
    self.update_attributes attributes
  end  
  
  def hit!
    self.class.increment_counter :hits, id
  end
  
  def accept_comments?
    !locked?
  end

  def paged?
    posts_count > Post.per_page
  end
  
  def last_page
    @last_page ||= [(comments_count.to_f / section.articles_per_page.to_f).ceil.to_i, 1].max
  end

  def previous
    section.topics.find :first, :conditions => ['last_updated_at < ?', last_updated_at], :order => :last_updated_at
  end

  def next
    section.topics.find :first, :conditions => ['last_updated_at > ?', last_updated_at], :order => :last_updated_at
  end
  
  def after_comment_update(post)
    if post = post.frozen? ? recent_post : post
      update_attributes! :last_updated_at => post.created_at,
                         :last_comment_id => post.id,
                         :last_author => post.author,
                         :comments_count => posts.count
    else
      self.destroy
    end
    update_forum
  end

  protected
    def set_site
      self.site_id = section.site_id if site_id.nil? && section
    end
  
    def set_default_attributes
      self.sticky          ||= 0
      self.last_updated_at ||= Time.now.utc
    end
    
    def update_forum
      section.after_topic_update(self)
    end
end