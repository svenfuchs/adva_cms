class Photo < ActiveRecord::Base
  cattr_accessor :base_dir
  @@base_dir = RAILS_ROOT + '/public/photos'
  
  acts_as_role_context  :parent => Section
  acts_as_taggable
  
  belongs_to_author
  belongs_to        :section
  has_many_comments :polymorphic => true
  
  has_attachment :storage     => :file_system,
                 :thumbnails  => { :large => '300', :thumb => '120>', :tiny => '50>' },
                 :max_size    => 30.megabytes,
                 :processor   => (Object.const_defined?(:ASSET_IMAGE_PROCESSOR) ? ASSET_IMAGE_PROCESSOR : nil)
  
  before_validation_on_create :set_values_from_parent
  before_create :set_position
  
  validates_presence_of   :title
  validates_as_attachment
  validate :rename_unique_filename
  
  delegate :comment_filter, :to => :site
  delegate :accept_comments?, :to => :section
  
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

  def full_filename(thumbnail = nil)
    file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:file_system_path]
    File.join(base_dir, permalink, thumbnail_name_for(thumbnail))
  end
  
  after_attachment_saved do |record|
    File.chmod 0644, record.full_filename
    Photo.update_all ['thumbnails_count = ?', record.thumbnails.count], ['id = ?', record.id] unless record.parent_id
  end
  
  def save_attachment?
    @temp_paths && File.file?(temp_path.to_s)
  end
  
  protected
    def rename_unique_filename
      if (@old_filename || new_record?) && errors.empty? && section_id && filename
        i      = 1
        pieces = filename.split('.')
        ext    = pieces.size == 1 ? nil : pieces.pop
        base   = pieces * '.'
        while File.exists?(full_filename)
          write_attribute :filename, base + "_#{i}#{".#{ext}" if ext}"
          i += 1
        end
      end
    end
    
    def set_values_from_parent
      if parent_id
        self.author     = parent.author
        self.title      = parent.title
        self.section_id = parent.section_id
      end
    end
    
    def set_position
      self.position ||= section.photos.maximum(:position).to_i + 1 if section && !parent_id
    end

    def permalink
      date = created_at || Time.zone.now
      pieces = [date.year, date.month, date.day]
      pieces.unshift "sites/#{site.id}" if Site.multi_sites_enabled
      pieces * '/'
    end
end