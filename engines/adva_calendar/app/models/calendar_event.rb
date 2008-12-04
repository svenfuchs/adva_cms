class Location < ActiveRecord::Base
  has_many :events, :class_name => 'CalendarEvent'
end

class CalendarEvent < ActiveRecord::Base
  has_many :assets, :through => :asset_assignments
  has_many :asset_assignments, :foreign_key => :content_id # TODO shouldn't that be :dependent => :delete_all?
  has_many :categories
  belongs_to :location
  belongs_to :section
  belongs_to_author

  acts_as_taggable
  acts_as_role_context :parent => 'Section'

  filters_attributes :sanitize => :body_html, :except => [:body, :cached_tag_list]
  
  validates_presence_of :startdate
  validates_presence_of :title

  before_create :set_published
  
  
  named_scope :elapsed, lambda {{:conditions => ['startdate < ? AND (enddate IS ? OR enddate < ?)', Time.now, nil, Time.now], :order => 'enddate DESC'}}
  named_scope :upcoming, Proc.new {|date| {:conditions => ['startdate > ? OR (startdate < ? AND enddate > ?)', date||Time.now, date||Time.now, date||Time.now], :order => 'startdate ASC'}}
  named_scope :recently_added, lambda{{:conditions => ['startdate > ? OR (startdate < ? AND enddate > ?)', Time.now, Time.now, Time.now], :order => 'created_at DESC'}}

  def set_published
    self.published_at = Time.zone.now
  end

  def validate
    errors.add(:enddate, 'must be after start date') if ! self.enddate.nil? and self.enddate < self.startdate 
  end
end
