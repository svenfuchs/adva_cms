class Comment < ActiveRecord::Base
  class CommentNotAllowed < StandardError; end  
  
  class Jail < Safemode::Jail
    allow :new_record?
  end  
  
  filters_attributes :sanitize => :body_html
  filtered_column :body  

  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to_author

  validates_presence_of :body, :author_id, :commentable_id, :commentable_type 
  
  before_create :authorize_commenting
  
  # TODO where are these needed? can we remove them from here? 
  # this model rather should not have any knowledge about sites and sections
  delegate :section, :to => :commentable
  delegate :site, :to => :section
  
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
end