class Comment < ActiveRecord::Base
  class CommentNotAllowed < StandardError; end  
  
  class Jail < Safemode::Jail
    allow :new_record?
  end  

  before_validation  :set_site, :set_section
  after_create  :update_commentable
  after_destroy :update_commentable

  filters_attributes :sanitize => :body_html
  filtered_column :body  

  belongs_to :site
  belongs_to :section
  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to_author

  validates_presence_of :body, :author_id, :commentable
  
  before_create :authorize_commenting
  
  def filter
    commentable.comment_filter
  end
  
  def approved?
    approved.to_s == '1'
  end

  def unapproved?
    !approved?
  end

  def authorize_commenting
    raise CommentNotAllowed, "Comments are not allowed for this #{commentable.class.name.demodulize.humanize.downcase}." unless commentable.accept_comments?
  end   
  
  private
    def set_site
      self.site = commentable.site
    end
    
    def set_section
      self.section = commentable.section
    end
  
    def update_commentable
      commentable.after_comment_update(self) if commentable.respond_to? :after_comment_update
    end  
  
end