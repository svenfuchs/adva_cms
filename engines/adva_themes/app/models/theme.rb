require_dependency 'theme/file'
  
# root_dir  » #{RAILS_ROOT}/public/themes
# base_dir  » #{RAILS_ROOT}/public/themes/#{site.host}
# path      » #{RAILS_ROOT}/public/themes/#{site.host}/#{theme.theme_id}
# url       „                      themes/#{site.host}/#{theme.theme_id}

class Theme < ActiveRecord::Base
  cattr_accessor :root_dir
  @@root_dir = "#{RAILS_ROOT}/public"
  @@default_preview = "#{RAILS_ROOT}/public/images/adva_cms/preview.png"

  class << self
    def base_dir
      "#{root_dir}/themes"
    end
  end
  
  belongs_to :site
  has_many :files, :dependent => :destroy
  has_many :templates
  has_many :images
  has_many :javascripts
  has_many :stylesheets
  has_one  :preview
  
  has_permalink :name, :url_attribute => :theme_id, :scope => :site_id, 
                       :only_when_blank => false, :sync_url => true
  
  validates_presence_of :name
  
  after_create  :create_theme_dir, :create_preview
  after_destroy :delete_theme_dir
  
  def activate!
    update_attributes! :active => true
  end
  
  def deactivate!
    update_attributes! :active => false
  end
  
  def author_link
    name = author.blank? ? I18n.t(:'adva.common.unknown') : author
    homepage.blank? ? name : %(<a href="#{homepage}">#{name}</a>)
  end
  
  def path
    Site.multi_sites_enabled ? 
      "#{self.class.base_dir}/site-#{site.id}/#{theme_id}" : 
      "#{self.class.base_dir}/#{theme_id}"
  end
  
  def url
    Site.multi_sites_enabled ? 
      "themes/#{site.perma_host}/#{theme_id}" : 
      "themes/#{theme_id}"
  end
  
  # def to_param
  #   theme_id
  # end
  
  protected
  
    def create_theme_dir
      FileUtils.mkdir_p(path)
    end
  
    def create_preview
      self.preview = Preview.create! :theme => self, :data => ::File.new(@@default_preview)
    end
  
    def delete_theme_dir
      FileUtils.rm_rf(path)
    end
end