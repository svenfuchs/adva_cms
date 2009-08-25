require_dependency 'theme/file'

# root_dir  » #{RAILS_ROOT}/public
# base_dir  » #{RAILS_ROOT}/public/sites/site-#{site.id}/themes
# path      » #{RAILS_ROOT}/public/sites/site-#{site.id}/themes/#{theme.theme_id}
# url       „                                            themes/#{theme.theme_id}

# default theme cache folder is appendod to following paths:
#     » #{RAILS_ROOT}/public/sites/site-#{site.id}/themes/stylesheets
#     » #{RAILS_ROOT}/public/sites/site-#{site.id}/themes/javascripts

class Theme < ActiveRecord::Base
  cattr_accessor :root_dir
  @@root_dir = "#{RAILS_ROOT}/public"

  cattr_accessor :default_preview
  @@default_preview = "#{::File.dirname(__FILE__)}/../../public/images/adva_themes/preview.png"
  
  THEME_STRUCTURE = ['stylesheets', 'javascripts', 'images', 'templates']
  
  class << self
    def base_dir(site)
      "#{root_dir}/sites/site-#{site.id}/themes"
    end
  end

  belongs_to :site
  has_many :files, :order => "directory ASC, name ASC", :dependent => :delete_all
  has_many :templates, :order => "directory ASC, name ASC"
  has_many :images, :order => "directory ASC, name ASC"
  has_many :javascripts, :order => "directory ASC, name ASC"
  has_many :stylesheets, :order => "directory ASC, name ASC"
  has_one  :preview

  has_permalink :name, :url_attribute => :theme_id, :scope => :site_id,
                       :only_when_blank => false, :sync_url => true

  validates_presence_of :name
  
  after_create  :create_theme_dir, :create_preview
  after_destroy :delete_theme_dir

  class << self
    def import(file)
      name = file.original_filename.to_s.gsub(/(^.*(\\|\/))|(\.zip$)/, '').gsub(/[^\w\.\-]/, '_')
      return false unless valid_theme?(file)
      returning Theme.create(:name => name) do |theme|
        theme.import(file)
      end
    end

    def make_tmp_dir
      random = Time.now.to_i.to_s.split('').sort_by { rand }
      returning Pathname.new(Rails.root + "/tmp/themes/tmp_#{random}/") do |dir|
        FileUtils.mkdir_p(dir) unless dir.exist?
      end
    end
    
    def valid_theme?(file)
      valid = false
      Zip::ZipFile.open(file.path) do |zip|
        zip.sort.each do |entry|
          entry.name.split('/').each do |file|
            valid = true if THEME_STRUCTURE.include?(file)
          end
        end
      end
      valid
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
    name = author.present? ? author : I18n.t(:'adva.common.unknown')
    homepage.present? ? %(<a href="#{homepage}">#{name}</a>) : name
  end

  def path
    "#{self.class.base_dir(site)}/#{theme_id}"
  end

  def url
    "sites/site-#{site.id}/themes/#{theme_id}"
  end

  def import(file)
    file = returning ActionController::UploadedTempfile.new("uploaded-theme") do |f|
      f.write file.read
      f.original_path = file.original_path
      f.read # no idea why we need this here, otherwise the zip can't be opened
    end unless file.path
    
    theme_root = Theme.find_theme_root(file)
    
    Zip::ZipFile.open(file.path) do |zip|
      zip.each do |entry|
        if entry.name == 'about.yml'
          # FIXME
        else
          name = entry.name.sub(/__MACOSX\//, '')
          name = Theme.strip_path(entry.name, theme_root)
          data = ''
          entry.get_input_stream { |io| data = io.read }
          data = StringIO.new(data) if data.present?
          Theme::File.create!(:theme => self, :base_path => name, :data => data) rescue next
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
  
  def cached_files
    Dir.glob("#{path}/**/*").select { |file| file if /cached_|\/cached\//.match(file) }
  end
  
  def clear_asset_cache!
    cached_files.each { |file| FileUtils.rm_r(file) if ::File.exists?(file) }
  end
  
  # def to_param
  #   theme_id
  # end

  protected

    def create_theme_dir
      FileUtils.mkdir_p(path)
    end

    def create_preview
      self.preview = Preview.new :theme => self, :data => ::File.new(default_preview)
    end

    def delete_theme_dir
      FileUtils.rm_rf(path)
    end
    
    # FIXME I think there should be another class that have these methods, along with importing itself
    #       they do not seem to fit on theme class. But works for now.
    class << self
      def find_theme_root(file)
        theme_root = ''
        Zip::ZipFile.open(file.path) do |zip|
          zip.each do |entry|
            entry.name.sub!(/__MACOSX\//, '')
            if theme_root = root_in_path(entry.name)
              break
            end
          end
        end
        theme_root
      end
  
      def root_in_path(path)
        root_found = false
        theme_root = ''
        path.split('/').each do |piece|
          if piece == 'about.yml' || THEME_STRUCTURE.include?(piece)
            root_found = true
          else
            theme_root += piece + '/' if !piece.match('\.') && !root_found
          end
        end
        root_found ? theme_root : false
      end

      def strip_path(file_name, path)
        file_name.sub(path, '')
      end
    end
end