class Article < Content
  default_scope :order => "#{self.table_name}.published_at DESC"

  filters_attributes :except => [:excerpt, :excerpt_html, :body, :body_html, :cached_tag_list]

  before_create :set_position

  validates_presence_of :title, :body
  validates_uniqueness_of :permalink, :scope => :section_id

  has_filter :tagged, :categorized,
             :text  => { :attributes => [:title, :body, :excerpt] },
             :state => { :states => [:published, :unpublished] }

  if Rails.plugin?(:adva_safemode)
    class Jail < Content::Jail
      # allow :title, :permalink, :type, :body, :comments, :author, :section, :categories, :published_at, :version
    end
  end

  class << self
    def find_by_permalink(*args)
      options = args.extract_options!
      permalink = args.pop
      if args.present?
        published(*args).find_by_permalink(permalink, options)
      else
        find :first, options.merge(:conditions => ["#{self.table_name}.permalink = ?", permalink])
      end
    end
  end

  def primary?
    self == section.articles.primary
  end

  def previous
    section.articles.published(:conditions => ["#{self.class.table_name}.published_at < ?", published_at], :limit => 1).first
  end

  def next
    section.articles.published(:conditions => ["#{self.class.table_name}.published_at > ?", published_at], :limit => 1).first
  end

  def has_excerpt?
    return false if excerpt == "<p>&#160;</p>" # empty excerpt with fckeditor
    excerpt.present?
  end

  def move_to(attributes = {})
    left_id = attributes[:left_id]
    left = left_id && left_id != 'null' ? self.class.find(left_id).position : 0
    self.class.connection.update("UPDATE #{self.class.table_name} SET position = position + 1 WHERE position > #{left}")
    self.update_attributes(:position => left + 1)
  end

  protected

    def set_position
      self.position ||= section.articles.maximum(:position).to_i + 1 if section
    end
end
