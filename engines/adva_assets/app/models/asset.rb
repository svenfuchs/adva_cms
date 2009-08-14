Paperclip::Attachment.interpolations.merge! \
  :asset_file_url  => proc { |data, style| data.instance.url(style)  },
  :asset_file_path => proc { |data, style| data.instance.path(style) }

# FIXME how to tell paperclip to only create thumbnails etc from images?

require 'has_filter'

class Asset < ActiveRecord::Base
  cattr_accessor :root_dir
  @@root_dir = "#{RAILS_ROOT}/public"

  # used for recognizing exceptional mime types
  @@content_types = {
    :image => [],
    :audio => ['application/ogg', 'application/x-wav'],
    :video => ['application/x-shockwave-flash', 'application/x-mov'],
    :pdf   => ['application/pdf', 'application/x-pdf']
  }
  cattr_reader :content_types

  # do we really want this? or do we want to just overwrite existing assets
  # instead? or even add a config option?
  before_save :ensure_unique_filename

  belongs_to :site
  has_many :contents, :through => :asset_assignments
  has_many :asset_assignments, :order => 'position', :dependent => :delete_all
  acts_as_taggable
  
  has_filter :tagged, :text => { :attributes => [:data_file_name, :title] }

  has_attached_file :data, :styles => { :medium => "300x300>", :thumb => "120x120#", :tiny => "50x50#" },
                           :url    => ":asset_file_url",
                           :path   => ":asset_file_path"

  validates_presence_of :site_id
  validates_attachment_presence :data
  validates_attachment_size :data, :less_than => 30.megabytes

  named_scope :is_media_type, lambda { |types|
    content_type_conditions(types)
  }

  # no idea where these would ever be used?
  content_types.keys.each do |type|
    named_scope type.to_s.pluralize, lambda {
      content_type_conditions(type)
    }
  end
  named_scope :others, lambda {
    content_type_conditions(content_types.keys - [:pdf], :exclude => true )
  }

  class << self
    def base_url(site)
      "/sites/site-#{site.id}/assets"
    end

    def base_dir(site)
      "#{root_dir}/sites/site-#{site.id}/assets"
    end
    
    [:image, :video, :audio, :pdf, :other].each do |type|
      define_method("#{type}?") do |content_type|
        Mime::Type.lookup(content_type).to_s.starts_with(type.to_s) ||
          content_types[type].try(:include?, content_type) || false
      end
    end

    def other?(content_type)
      ![:image, :video, :audio, :pdf].any? { |type| send(:"#{type}?", content_type) }
    end

    protected

      def content_type_conditions(types, options = {})
        types = Array(types)
        operator, negator = options[:exclude] ? [' AND ', 'NOT '] : [' OR ', nil]

        patterns = types.map { |type| "#{type}%" }
        types    = types.map &:to_sym
        values   = content_types.slice(*types).values.flatten
        query    = ["data_content_type #{negator}IN (?)"] +
                   [" data_content_type #{negator}LIKE ?"] * types.size

        { :conditions => [query.join(operator), values, *patterns] }
      end
  end

  def title
    t = read_attribute(:title)
    t.present? ? t : data_file_name
  end

  [:image, :video, :audio, :pdf, :other].each do |type|
    define_method("#{type}?") { self.class.send("#{type}?", data_content_type) }
  end

  def base_url(style = :original, fallback = false)
    style = :original unless style == :original or File.exists?(path(style))
    [self.class.base_url(self.site), filename(style)].to_path
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
