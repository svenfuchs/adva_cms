require 'html_diff'

# Let's have a :tag option for finders
ActiveRecord::Base.class_eval do
  class << self
    VALID_FIND_OPTIONS << :tags
  end
end

WillPaginate::Finder::ClassMethods.class_eval do
  alias :wp_count_without_tags :wp_count unless method_defined? :wp_count_without_tags
  def wp_count(options, *args)
    wp_count_without_tags(options.except(:tags), *args)
  end
end

class Content < ActiveRecord::Base
  acts_as_versioned :if_changed => [:title, :body, :excerpt], :limit => 5
  class Version < ActiveRecord::Base
    filters_attributes :none => true
  end
    
  acts_as_taggable
  acts_as_role_context :parent => Section
  has_many_comments :polymorphic => true
  non_versioned_columns << 'cached_tag_list' << 'assets_count' << 'state'
  instantiates_with_sti

  has_permalink :title, :scope => :section_id
  filtered_column :body, :excerpt

  belongs_to :site
  belongs_to :section
  belongs_to_author

  has_many :assets, :through => :asset_assignments
  has_many :asset_assignments # TODO shouldn't that be :dependent => :delete_all?
  has_many :categories, :through => :category_assignments
  has_many :category_assignments # TODO shouldn't that be :dependent => :delete_all?
  has_many :activities, :as => :object # move to adva_activity?

  before_validation :set_site
  # after_save :save_categories

  class_inheritable_reader :default_find_options
  write_inheritable_attribute :default_find_options, { :order => 'position, published_at' }
  delegate :comment_filter, :to => :site
  delegate :accept_comments?, :to => :section

  validates_presence_of :title, :body
  validates_uniqueness_of :permalink, :scope => :section_id

  # acts_as_indexed :fields => [:title, :body, :author]
  # before_validation { |record| record.set_default_filter! }

  class << self
    def find_every(options)
      options = default_find_options.merge(options)
      if tags = options.delete(:tags)
        options = find_options_for_find_tagged_with(tags, options.update(:match_all => true))
      end
      super options
    end
    
    def find_published_in_time_delta(*args, &block)
      with_published { find_in_time_delta *args, &block }
    end

    def find_in_time_delta(*args)
      options = args.extract_options!
      with_time_delta *args do find(:all, options) end
    end

    def with_published(&block)
      conditions = ['contents.published_at <= ? AND contents.published_at IS NOT NULL', Time.zone.now]
      with_scope({:find => {:conditions => conditions}}, &block)
    end

    def with_time_delta(*args, &block)
      return yield if args.compact.empty?
      conditions = ["contents.published_at BETWEEN ? AND ?", *Time.delta(*args)]
      with_scope({:find => {:conditions => conditions}}, &block)
    end

    def method_missing(name, *args, &block)
      if name.to_s =~ /find_(all_)?published/
        with_published { send name.to_s.sub('_published', ''), *args, &block }
      else
        super
      end
    end
  end

  def owner
    section
  end

  # Using callbacks for such lowlevel things is just awkward. So let's hook in here.
  def attributes=(attributes, guard_protected_attributes = true)
    attributes.symbolize_keys!
    category_ids = attributes.delete(:category_ids)
    returning super do update_categories category_ids if category_ids end
  end

  def comments_expired_at
    if comment_age == -1
      9999.years.from_now
    else
      (published_at || Time.zone.now) + comment_age.days
    end
  end

  def diff_against_version(version)
    # return '(orginal version)' if version == versions.earliest.version
    version = versions.find_by_version(version)
    HtmlDiff.diff version.excerpt_html + version.body_html, excerpt_html + body_html
  end

  protected

    def set_site
      self.site_id = section.site_id if section
    end

    def update_categories(category_ids)
      categories.each do |category|
        category_ids.delete(category.id.to_s) || categories.delete(category)
      end
      unless category_ids.blank?
        categories << Category.find(:all, :conditions => ['id in (?)', category_ids])
      end
    end

    # This is from Mephisto. Does it still make any sense? Can we kill it?
    #
    # def set_filter_from(filtered_object)
    #   self.filter = filtered_object.filter
    # end
    #
    # def set_default_filter_from(filtered_object)
    #   set_filter_from(filtered_object) if filter.nil?
    # end
    #
    # def set_default_filter!
    #   set_default_filter_from user
    # end
end
