Paperclip::Attachment.interpolations.merge! \
  :photo_file_url  => proc { |data, style| data.instance.url(style)  },
  :photo_file_path => proc { |data, style| data.instance.path(style) }

Category.class_eval do
  has_many :photos, :through => :categorizations, :source => :categorizable, :source_type => 'Photo'
end

class Photo < ActiveRecord::Base
  cattr_accessor :root_dir
  @@root_dir = "#{RAILS_ROOT}/public"

  acts_as_taggable

  belongs_to_author
  belongs_to :section
  has_many :sets, :source => 'category', :through => :categorizations
  has_many :categorizations, :as => :categorizable, :dependent => :destroy, :include => :category

  has_attached_file :data, :styles => { :large => "600x600>", :thumb => "120x120>", :tiny => "50x50#" },
                           :url    => ":photo_file_url",
                           :path   => ":photo_file_path"

  default_scope :order => 'published_at desc'

  named_scope :published, lambda {
    { :conditions => ['published_at IS NOT NULL AND published_at <= ?', Time.zone.now] } }

  named_scope :drafts, lambda {
    { :conditions => ['published_at IS NULL'] } }

  named_scope :by_set, lambda { |set|
    {
      :include => :sets,
      :conditions => ["categories.lft >= ? AND categories.rgt <= ?", set.lft, set.rgt]
    }
  }

  before_save :ensure_unique_filename

  validates_presence_of :title
  validates_attachment_presence :data
  validates_attachment_size :data, :less_than => 30.megabytes

  class << self
    def base_url(site)
      "/sites/site-#{site.id}/photos"
    end

    def base_dir(site)
      "#{root_dir}/sites/site-#{site.id}/photos"
    end
  end

  def draft?
    published_at.nil?
  end

  def published?
    !published_at.nil? and published_at <= Time.zone.now
  end

  def pending?
    !published?
  end

  def state
    pending? ? :pending : :published
  end

  def base_url(style = :original, fallback = false)
    style = :original unless style == :original or File.exists?(path(style))
    [self.class.base_url(site), filename(style)].to_path
  end

  def path(style = :original)
    [self.class.base_dir(site), filename(style)].to_path
  end

  def filename(style = :original)
    style == :original ? data_file_name : [basename, style, extname].to_path('.')
  end

  def basename
    data_file_name.gsub(/\.#{extname}$/, "")
  end

  def extname
    File.extname(data_file_name).gsub(/^\.+/, '')
  end

  def site
    section.site
  end

  protected
    def ensure_unique_filename
      if new_record? || changes['data_file_name']
        basename, extname = self.basename, self.extname
        i = extname =~ /^\d+\./ ? $1 : 1
        while File.exists?(path)
          self.data_file_name = [basename, i, extname].to_path('.')
          i += 1
        end
      end
    end
end