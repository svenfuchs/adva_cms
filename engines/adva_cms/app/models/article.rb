class Article < Content
=begin
  class Jail < Safemode::Jail
    allow :title, :full_permalink, :excerpt_html, :body_html, :published_at,
          :section, :categories, :tags, :approved_comments, :accept_comments?,
          :comments_count, :has_excerpt?
  end
=end

  default_scope :order => 'published_at desc'

  filters_attributes :except => [:excerpt, :excerpt_html, :body, :body_html, :cached_tag_list]

  before_create :set_position

  validates_presence_of :title, :body
  validates_uniqueness_of :permalink, :scope => :section_id
  
  class << self
    def find_by_permalink(*args)
      options = args.extract_options!
      permalink = args.pop
      unless args.empty?
        published(*args).find_by_permalink(permalink, options)
      else
        find :first, options.merge(:conditions => ['permalink = ?', permalink])
      end
    end
  end

  def full_permalink
    raise "can not create full_permalink for an article that belongs to a non-blog section" unless section.is_a? Blog
    # raise "can not create full_permalink for an unpublished article" unless published?
    date = [:year, :month, :day].map { |key| [key, (published? ? published_at : created_at).send(key)] }.flatten
    Hash[:permalink, permalink, *date]
  end

  def primary?
    section.articles.primary == self
  end

  def previous
    section.articles.published(:conditions => ['published_at < ?', published_at], :limit => 1).first
  end

  def next
    section.articles.published(:conditions => ['published_at > ?', published_at], :limit => 1).first
  end

  def has_excerpt?
    !excerpt.blank?
  end
  
  protected

    def set_position
      self.position ||= section.articles.maximum(:position).to_i + 1 if section
    end
end
