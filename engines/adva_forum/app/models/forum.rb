class Forum < Section
  has_option :topics_per_page, :default => 25
  has_option :posts_per_page, :default => 10
  has_option :latest_topics_count, :default => 10
  # has_option :posts_per_page, :default => 25

  has_counter :topics, :as => :section
  has_many_posts :foreign_key => :section_id, :as => :section

  has_many :boards, :foreign_key => :section_id
  has_many :topics, :foreign_key => :section_id, :dependent => :delete_all,
                    :order => "topics.sticky DESC, topics.last_updated_at DESC, topics.id DESC"


  validates_numericality_of :topics_per_page, :only_integer => true, :message => :only_integer
  # TODO validates_inclusion_of :topics_per_page, :in => 1..30, :message => "can only be between 1 and 30."

  validates_numericality_of :posts_per_page, :only_integer => true, :message => :only_integer
  # TODO validates_inclusion_of :posts_per_page, :in => 1..30, :message => "can only be between 1 and 30."

  validates_numericality_of :latest_topics_count, :only_integer => true, :message => :only_integer

  before_create :set_content_filter

  class << self
    def content_type
      'Topic'
    end
  end
  
  def has_boards?
    boards.size != 0
  end

  def latest_topics
    topics.find(:all, :order => 'last_updated_at DESC', :limit => latest_topics_count)
  end

  def boardless_topics
    topics.find(:all, :conditions => ["board_id IS NULL"])
  end

  protected
    def set_content_filter
      self.content_filter = 'textile_filter'
    end
end