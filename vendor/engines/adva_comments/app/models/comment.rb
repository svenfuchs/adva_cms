class Comment < ActiveRecord::Base
  class CommentNotAllowed < StandardError; end  
  
  class Jail < Safemode::Jail
    allow :new_record?
  end  

  acts_as_role_context :roles => :author  
  filters_attributes :sanitize => :body_html
  filtered_column :body  

  belongs_to :site
  belongs_to :section
  belongs_to :commentable, :polymorphic => true
  belongs_to_author

  validates_presence_of :body, :commentable
  
  before_validation  :set_owners
  before_create :authorize_commenting
  after_save    :update_commentable
  after_destroy :update_commentable
  
  def owner
    commentable
  end
  
  def filter
    commentable.comment_filter
  end

  def unapproved?
    !approved?
  end
  
  def just_approved?
    approved? && approved_changed?
  end
  
  def just_unapproved?
    !approved? && approved_changed? 
  end
  
  def spam_info
    read_attribute(:spam_info) || {}
  end
  
  has_many :spam_reports, :as => :subject
  
  def spam_threshold
    50 # TODO have a config option on site for this
  end
  
  def ham?
    spaminess < spam_threshold
  end
  
  def spam?
    spaminess >= spam_threshold
  end
  
  def check_approval(context = {})
    section.spam_engine.check_comment(self, context)
    self.spaminess = calculate_spaminess
    self.approved = ham?
    save!
  end
  
  def calculate_spaminess
    sum = spam_reports(true).inject(0){|sum, report| sum + report.spaminess }
    sum > 0 ? sum / spam_reports.count : 0
  end

  protected
  
    def authorize_commenting
      unless commentable.accept_comments?
        raise CommentNotAllowed, "Comments are not allowed for this #{commentable.class.name.demodulize.humanize.downcase}." 
      end
    end
  
    def set_owners
      if commentable # TODO in what cases would commentable be nil here?
        self.site = commentable.site 
        self.section = commentable.section
      end
    end
  
    def update_commentable
      commentable.after_comment_update(self) if commentable && commentable.respond_to?(:after_comment_update)
    end  
  
end