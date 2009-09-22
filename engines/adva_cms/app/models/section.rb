class Section < ActiveRecord::Base
  @@types = ['Page']
  cattr_reader :types

  translates :title
  serialize :permissions

  has_option :contents_per_page, :default => 15
  has_permalink :title, :url_attribute => :permalink, :sync_url => true,
    :only_when_blank => true, :scope => [ :site_id, :parent_id ]
  acts_as_nested_set :scope => :site_id
  instantiates_with_sti

  belongs_to :site
  has_many :categories, :dependent => :destroy, :order => 'lft' do
    def roots
      find(:all, :conditions => { :parent_id => nil }, :order => 'lft')
    end

    def update_paths!
      paths = Hash[*roots.map { |r|
        r.self_and_descendants.map { |n| [n.id, { 'path' => n.send(:build_path) }] } }.flatten]
      update(paths.keys, paths.values)
    end
  end

  before_save  :update_path
  before_create :set_as_published
  after_create :update_paths

  validates_presence_of :title # :site wtf ... this breaks install_controller#index
  validates_uniqueness_of :permalink, :scope => :site_id
  validates_numericality_of :contents_per_page, :only_integer => true, :message => :only_integer

  # validates_each :template, :layout do |record, attr, value|
  #   record.errors.add attr, 'may not contain dots' if value.index('.') # FIXME i18n
  #   record.errors.add attr, 'may not start with a slahs' if value.index('.') # FIXME i18n
  # end

  # TODO validates_inclusion_of :contents_per_page, :in => 1..30, :message => "can only be between 1 and 30."

  class << self
    def register_type(type)
      @@types << type
      @@types.uniq!
    end
  end

  def owners
    owner.owners << owner
  end

  def owner
    site
  end

  def type
    read_attribute(:type) || 'Section'
  end

  def tag_counts
    Content.tag_counts :conditions => "section_id = #{id}"
  end

  def root_section?
    self == site.sections.root
  end

  def state
    published? ? :published : :pending
  end

  def published=(published)
    if published.to_i == 1
      self.published_at = Time.current if !published_at
    elsif published.to_i == 0
      self.published_at = nil
    end
  end
  
  def published?(parents = false)
    return true if self == site.sections.root # the root section is always published
    return false if parents && has_unpublished_ancestor?
    return false if published_at.nil? || published_at > Time.current
    return true
  end
  alias published published?

  protected
  
    def set_as_published
      self.published_at = published_at || Time.current
    end
  
    def has_unpublished_ancestor?
      !ancestors.reject(&:published?).empty?
    end

    def update_path
      if permalink_changed?
        new_path = build_path
        unless self.path == new_path
          self.path = new_path
          @paths_dirty = true
        end
      end
    end

    def build_path
      self_and_ancestors.map(&:permalink).join('/')
    end

    def update_paths
      if parent_id
        move_to_child_of(parent)
        site.sections.update_paths!
      end
    end
end