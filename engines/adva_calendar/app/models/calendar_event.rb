
class CalendarEvent < ActiveRecord::Base
  has_many :assets, :through => :asset_assignments
  has_many :asset_assignments, :foreign_key => :content_id # TODO shouldn't that be :dependent => :delete_all?
  has_many :category_assignments, :foreign_key => 'content_id'
  has_many :categories, :through => :category_assignments
  belongs_to :location
  belongs_to :section
  belongs_to :user

  has_permalink :title, :scope => :section_id
  acts_as_taggable
  acts_as_role_context :parent => Calendar

  filtered_column :body

  validates_presence_of :startdate
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :section_id
  validates_uniqueness_of :permalink, :scope => :section_id
  
  before_create :set_published

  named_scope :by_categories, Proc.new {|category_ids| {:conditions => ['category_assignments.category_id IN (?)', category_ids], :include => :category_assignments}}
  named_scope :elapsed, lambda {{:conditions => ['startdate < ? AND (enddate IS ? OR enddate < ?)', Time.now, nil, Time.now], :order => 'enddate DESC'}}
  named_scope :upcoming, Proc.new {|startdate, enddate| {:conditions => ['startdate > ? OR (startdate < ? AND enddate > ?)', startdate||Time.now, startdate||Time.now, enddate||Time.now], :order => 'startdate ASC'}}
  named_scope :recently_added, lambda{{:conditions => ['startdate > ? OR (startdate < ? AND enddate > ?)', Time.now, Time.now, Time.now], :order => 'created_at DESC'}}

  named_scope :search, Proc.new{|query, filter| {:conditions => ["#{CalendarEvent.sanitize_filter(filter)} LIKE ?", "%%%s%%" % query]}}

  def self.sanitize_filter(filter)
    %w(title body).include?(filter) ? filter : 'title'
  end
  def set_published
    self.published_at = Time.zone.now
  end

  def validate
    errors.add(:enddate, 'must be after start date') if ! self.enddate.nil? and self.enddate < self.startdate 
  end
end
