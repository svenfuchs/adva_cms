require_dependency 'theme/file'

# root_dir  » #{RAILS_ROOT}/public/themes
# base_dir  » #{RAILS_ROOT}/public/themes/#{site.host}
# path      » #{RAILS_ROOT}/public/themes/#{site.host}/#{theme.theme_id}
# url       „                      themes/#{site.host}/#{theme.theme_id}

class Theme < ActiveRecord::Base
  cattr_accessor :root_dir
  @@root_dir = "#{RAILS_ROOT}/public"

  cattr_accessor :default_preview
  @@default_preview = "#{::File.dirname(__FILE__)}/../../public/images/adva_themes/preview.png"

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

  class << self
    def import(file)
      name = file.original_filename.gsub(/(^.*(\\|\/))|(\.zip$)/, '').gsub(/[^\w\.\-]/, '_')
      returning Theme.create(:name => name) do |theme|
        theme.import(file)
      end
    end

    def make_tmp_dir
      random = Time.now.to_i.to_s.split('').sort_by{rand}
      returning Pathname.new(Rails.root + "/tmp/themes/tmp_#{random}/") do |dir|
        FileUtils.mkdir_p dir unless dir.exist?
      end
    end
  end
  
  def others
    [preview]
  end

  def about
    %w(name author version homepage summary).inject({}) do |result, key|
      result[key] = send(key)
      result
    end
  end

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
      "themes/site-#{site.id}/#{theme_id}" :
      "themes/#{theme_id}"
  end

  def import(file)
    file = returning ActionController::UploadedTempfile.new("uploaded-theme") do |f|
      f.write file.read
      f.original_path = file.original_path
      f.read # no idea why we need this here, otherwise the zip can't be opened
    end unless file.path

    Zip::ZipFile.open(file.path) do |zip|
      zip.each do |entry|
        if entry.name == 'about.yml'
          # FIXME
        else
          data = ''
          entry.get_input_stream { |io| data = io.read }
          data = StringIO.new(data) unless data.blank?
          Theme::File.create!(:theme => self, :base_path => entry.name, :data => data) rescue next
        end
      end
    end
  end

  def export
    tmp_dir = Theme.make_tmp_dir
    returning(tmp_dir + "#{name}.zip") do |file_name|
      file_name.unlink if file_name.exist?
      Zip::ZipFile.open(file_name, Zip::ZipFile::CREATE) do |zip|
        files.each { |file| zip.add(file.base_path, file.path) if ::File.exists?(file.path) }
        ::File.open(tmp_dir + 'about.yml', 'w') { |f| f.write(about.to_yaml) }
        zip.add('about.yml', tmp_dir + 'about.yml')
      end
    end
  end

  # def to_param
  #   theme_id
  # end

  protected

    def create_theme_dir
      FileUtils.mkdir_p(path)
    end

    def create_preview
      self.preview = Preview.create! :theme => self, :data => ::File.new(default_preview)
    end

    def delete_theme_dir
      FileUtils.rm_rf(path)
    end
end