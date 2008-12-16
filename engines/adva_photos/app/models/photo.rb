class Photo < ActiveRecord::Base
  acts_as_role_context  :parent => Section
  acts_as_taggable
  
  belongs_to_author
  belongs_to        :section
  has_many_comments :polymorphic => true
  has_permalink     :title, :scope => :section_id
  
  has_attachment :storage     => :file_system,
                 :thumbnails  => { :thumb => '120>', :tiny => '50>' },
                 :max_size    => 30.megabytes,
                 :processor   => (Object.const_defined?(:ASSET_IMAGE_PROCESSOR) ? ASSET_IMAGE_PROCESSOR : nil)
  
  validates_presence_of   :title
  validates_uniqueness_of :permalink, :scope => :section_id
  validates_as_attachment
  
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
end