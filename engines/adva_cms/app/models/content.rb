require 'html_diff'

class Content < ActiveRecord::Base
  # TODO is this needed?
  class Version < ActiveRecord::Base
    filters_attributes :none => true
  end

  translates :title, :body, :excerpt, :body_html, :excerpt_html,
    :versioned  => [ :title, :body, :excerpt, :body_html, :excerpt_html ],
    :if_changed => [ :title, :body, :excerpt ], :limit => 5
  acts_as_taggable

  instantiates_with_sti
  has_permalink :title, :url_attribute => :permalink, :sync_url => true, :only_when_blank => true, :scope => :section_id
  filtered_column :body, :excerpt

  belongs_to :site
  belongs_to :section
  belongs_to_author :validate => true

  has_many :assets, :through => :asset_assignments
  has_many :asset_assignments # TODO :dependent => :delete_all?
  has_many :activities, :as => :object # move to adva_activity?
  has_many :categories, :through => :categorizations
  has_many :categorizations, :as => :categorizable, :dependent => :destroy, :include => :category

  before_validation :set_site

  # more explicit to make nested category contents to work
  default_scope :order => 'contents.position, contents.published_at'

  named_scope :published, Proc.new { |*args|
    options = args.extract_options!
    conditions = ['contents.published_at IS NOT NULL AND contents.published_at <= ?', Time.zone.now]
    add_time_delta_condition!(conditions, args) unless args.compact.empty?
    options.merge(:conditions => conditions)
  }

  named_scope :drafts, Proc.new { |*args|
    options = args.extract_options!
    conditions = ['contents.published_at IS NULL']
    add_time_delta_condition!(conditions, args) unless args.compact.empty?
    options.merge(:conditions => conditions)
  }

  named_scope :unpublished, Proc.new { |*args|
    drafts(*args).scope(:find)
  }

  named_scope :by_category, lambda { |category|
    section_type = category.section.class
    {
      :include => [:categories, :section],
      :conditions => [
        "categories.lft >= ? AND categories.rgt <= ? AND contents.type = ? AND sections.type = ?",
        category.lft, category.rgt, section_type.content_type, section_type.to_s
      ]
    }
  }

  class << self
    def add_time_delta_condition!(conditions, args)
      conditions.first << " AND contents.published_at BETWEEN ? AND ?"
      conditions.concat Time.delta(*args)
    end
  end

  def owners
    owner.owners << owner
  end

  def owner
    section
  end

  attr_accessor :draft
  def published_at=(published_at)
    write_attribute(:published_at, draft.to_i == 1 ? nil : published_at)
  end

  def author_id=(author_id)
    # FIXME this is only needed because belongs_to_cacheable can't be non-polymorphic, yet
    self.author = User.find(author_id) if author_id
  end

  def attributes=(attributes, guard_protected_attributes = true)
    returning super do
      update_categories(attributes.delete(:category_ids))
    end
  end

  def published_month
    Time.local(published_at.year, published_at.month, 1)
  end

  def draft?
    published_at.nil?
  end

  def pending?
    !published?
  end

  def published?
    !published_at.nil? && published_at <= Time.zone.now
  end

  def published_at?(date)
    published? && date == [:year, :month, :day].map { |key| published_at.send(key).to_s }
  end

  def state
    pending? ? :pending : :published
  end

  def just_published?
    published? && published_at_changed?
  end

  def diff_against_version(version)
    # return '(orginal version)' if version == versions.earliest.version
    version = versions[version]
    HtmlDiff.diff(version.excerpt_html + version.body_html, excerpt_html + body_html)
  end

  # def to_param(key)
  #   value = if self.respond_to?(key)
  #     self.send(key)
  #   elsif [:year, :month, :day].include?(key)
  #     published_at.send(key)
  #   else
  #     super()
  #   end
  #   value ? value.to_s : nil
  # end

  protected

    def set_site
      self.site_id = section.site_id if section
    end

    def update_categories(category_ids)
      category_ids = Array(category_ids).reject(&:blank?)
      return if category_ids.empty?

      categories.each do |category|
        category_ids.delete(category.id.to_s) || categories.delete(category)
      end
      if category_ids.present?
        categories << Category.find(:all, :conditions => ['id in (?)', category_ids])
      end
    end
end