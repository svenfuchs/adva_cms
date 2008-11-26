class Calendar::Event < ActiveRecord::Base
  filters_attributes :sanitize => :body_html, :except => [:body, :cached_tag_list]
  before_create :set_published
  set_table_name :calendar_events
  
  validates_presence_of :startdate
  validates_presence_of :title
  
  has_many :categories
  belongs_to :location
  
  named_scope :elapsed, lambda {{:conditions => ['startdate < ? AND (enddate = ? OR enddate < ?)', Time.now, nil, Time.now]}}

  def after_initialize
    self.title = permalink.to_s.gsub("-", " ").capitalize if new_record? && title.blank? && permalink
  end

  def set_published
    self.published_at = Time.zone.now
  end

  def validate
    errors.add(:enddate, 'must be after start date') if ! self.enddate.nil? and self.enddate < self.startdate 
  end


end
