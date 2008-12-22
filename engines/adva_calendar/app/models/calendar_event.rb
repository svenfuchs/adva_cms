
class CalendarEvent < ActiveRecord::Base
  has_many :assets, :through => :asset_assignments
  has_many :asset_assignments, :foreign_key => :content_id # TODO shouldn't that be :dependent => :delete_all?
  has_many :category_assignments, :foreign_key => 'content_id'
  has_many :categories, :through => :category_assignments
  belongs_to :location
  belongs_to :section
  alias :calendar :section
  belongs_to :user

  has_permalink :title, :scope => :section_id
  acts_as_taggable
  acts_as_role_context :parent => Calendar

  filters_attributes :sanitize => :body_html, :except => [:body, :cached_tag_list]
  filtered_column :body

  validates_presence_of :startdate
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :section_id
  validates_presence_of :location_id
  validates_uniqueness_of :permalink, :scope => :section_id

  named_scope :by_categories, Proc.new {|*category_ids| {:conditions => ['category_assignments.category_id IN (?)', category_ids], :include => :category_assignments}}
  named_scope :elapsed, lambda {{:conditions => ['startdate < ? AND (enddate IS ? OR enddate < ?)', Time.now, nil, Time.now], :order => 'startdate DESC'}}
  named_scope :upcoming, Proc.new {|startdate, enddate| {:conditions => ['(startdate > ? AND startdate < ?) OR (startdate < ? AND enddate > ?)', startdate||Time.now, enddate||((startdate||Time.now) + 1.month), startdate||Time.now, enddate||Time.now], :order => 'startdate ASC'}}
  named_scope :recently_added, lambda{{:conditions => ['startdate > ? OR (startdate < ? AND enddate > ?)', Time.now, Time.now, Time.now], :order => 'created_at DESC'}}

  named_scope :published, :conditions => {:draft => false }
  named_scope :search, Proc.new{|query, filter| {:conditions => ["#{CalendarEvent.sanitize_filter(filter)} LIKE ?", "%%%s%%" % query], :order => 'startdate DESC'}}

  def self.sanitize_filter(filter)
    %w(title body).include?(filter.to_s) ? filter.to_s : 'title'
  end

  def validate
    errors.add(:enddate, 'must be after start date') if ! self.enddate.nil? and self.enddate < self.startdate 
  end
  
  def all_day=(value)
    if value
      self.startdate = self.startdate.beginning_of_day unless self.startdate.blank?
      self.enddate = self.startdate.end_of_day unless self.enddate.blank?
    end
  end
  
  def all_day
    self.startdate == self.startdate.beginning_of_day and self.enddate == self.startdate.end_of_day unless self.startdate.blank? or self.enddate.blank?
  end
  
end
