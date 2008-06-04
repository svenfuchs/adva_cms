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
  belongs_to :section
  belongs_to :site
  belongs_to_author

  has_many :assets, :through => :asset_assignments
  has_many :asset_assignments
  has_many :categories, :through => :category_assignments, :dependent => :destroy
  has_many :category_assignments
  
  has_permalink :title, :scope => :section_id
  filtered_column :body, :excerpt
  
  acts_as_taggable
  acts_as_commentable :polymorphic => true
  acts_as_versioned :if_changed => [:title, :body, :excerpt, :user_id], :limit => 5
  non_versioned_columns << 'cached_tag_list' << 'assets_count' << 'state'
  instantiates_with_sti

  before_validation :set_site
  after_save :save_categories

  class_inheritable_reader :default_find_options
  write_inheritable_attribute :default_find_options, { :order => 'position, published_at' }
  delegate :comment_filter, :to => :site
  delegate :required_role_for, :to => :section

  validates_presence_of :title
  validates_uniqueness_of :permalink, :scope => :section_id
  
  # acts_as_indexed :fields => [:title, :body, :author]
  # before_validation { |record| record.set_default_filter! }
  
  class << self
    def find_every(options)
      if tags = options.delete(:tags)      
        options = find_options_for_find_tagged_with(tags, options.update(:match_all => true))
      end
      super options
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

  def attributes=(*args)
    @new_category_ids = args.first.delete(:category_ids)
    super
  end

  def comments_expired_at
    (published_at || Time.zone.now) + comment_age.days
  end
  
  def accept_comments?
    section.accept_comments?
  end
  
  def user_has_role?(user, role)
    role == :author && is_author?(user) or section.user_has_role?(user, role)
  end  
  
  def diff_against_version(version)
    return '(orginal version)' if version == versions.earliest.version
    HtmlDiff.diff versions.find_by_version(version).body, body
  end
  
  protected
  
    def set_site
      self.site_id = section.site_id if site_id.nil? && section
    end
   
    def save_categories
      return unless @new_category_ids
      categories.each do |category|
        @new_category_ids.delete(category.id.to_s) || categories.delete(category)
      end
      unless @new_category_ids.blank?
        categories << Category.find(:all, :conditions => ['id in (?)', @new_category_ids])
      end    
      @new_sections = nil
    end
    
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
