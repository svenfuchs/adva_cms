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

  validates_presence_of :title, :body
  validates_uniqueness_of :permalink, :scope => :section_id

  class << self
    def find_by_permalink(*args)
      options = args.extract_options!
      if args.size > 1
        permalink = args.pop
        with_time_delta(*args) do find_by_permalink(permalink, options) end
      else
        find :first, options.merge(:conditions => ['permalink = ?', args.first])
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
    section.articles.find_published :first, :conditions => ['published_at < ?', published_at], :order => :published_at
  end

  def next
    section.articles.find_published :first, :conditions => ['published_at > ?', published_at], :order => :published_at
  end
end
