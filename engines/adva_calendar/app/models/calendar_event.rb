
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

  validates_presence_of :start_date
  validates_presence_of :end_date, :if => :require_end_date?
  validates_presence_of :title
  validates_presence_of :user_id
  validates_presence_of :section_id
  validates_uniqueness_of :permalink, :scope => :section_id

  named_scope :by_categories, Proc.new { |*category_ids|
    {
      :conditions => ['category_assignments.category_id IN (?)', category_ids],
      :include => :category_assignments
    }
  }

  named_scope :elapsed, lambda {
    t = Time.now
    {
      :conditions => ['start_date <= ? AND (end_date IS NULL OR end_date <= ?)', t, t],
      :order => 'start_date DESC'
    }
  }

  named_scope :upcoming, Proc.new { |start_date, end_date|
    t = Time.now
    start_date ||= t
    end_date ||= start_date.end_of_day + 1.month
    {
      :conditions => ['(start_date BETWEEN ? AND ?) 
          OR (start_date <= ? AND end_date >= ?)', 
          start_date, end_date, start_date, start_date],
      :order => 'start_date ASC'
    }
  }

  named_scope :recently_added, lambda {
    t = Time.now
    {
      :conditions => ['start_date >= ? OR end_date >= ?', t, t],
      :order => 'calendar_events.id DESC'
    }
  }

  named_scope :published, :conditions => 'published_at IS NOT NULL'

  named_scope :search, Proc.new { |query, filter|
    {
      :conditions => ["#{CalendarEvent.sanitize_filter(filter)} LIKE ?", "%#{query}%"],
      :order => 'start_date DESC'
    }
  }
  cattr_accessor :require_end_date
  def require_end_date?
    !(self.class.require_end_date == false)
  end

  def draft?
    published_at.nil?
  end

  def self.sanitize_filter(filter)
    %w(title body).include?(filter.to_s) ? filter.to_s : 'title'
  end

  def validate
    errors.add(:end_date, 'must be after start date') if ! self.start_date.nil? and ! self.end_date.nil? and self.end_date < self.start_date
  end
end
