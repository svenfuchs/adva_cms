class Site < ActiveRecord::Base
  # TODO make sure the theme name doesn't have any slashes (forbid anything besides [\w\-_\.] ?)
  acts_as_themed
  acts_as_role_context :actions => ["manage themes", "manage assets"]
  has_many_comments

  serialize :permissions
  serialize :spam_options

  has_many :sections, :dependent => :destroy, :order => :lft do
    def root
      find_by_parent_id nil, :order => 'lft'
    end

    def paths
      map(&:path)
    end

    # TODO this is very expensive! change this to only update_paths when a node has been moved.
    # maybe move this to betternestedset and hook into move_by instead?
    def update_paths!
      paths = roots.collect do |root|
        root.full_set.collect {|node| [node.id, {'path' => node.send(:build_path)}] }
      end
      paths = Hash[*paths.flatten]
      update paths.keys, paths.values
    end
  end

  has_many :users, :through => :memberships, :dependent => :destroy
  has_many :memberships, :dependent => :delete_all

  has_many :assets, :order => 'assets.created_at desc', :conditions => 'parent_id is null', :dependent => :destroy do
    def recent
      find(:all, :limit => 6)
    end
  end
  has_many :cached_pages, :dependent => :destroy, :order => 'cached_pages.updated_at desc'

  before_validation :downcase_host, :replace_host_spaces # :permalinkaze_host
  before_validation :downcase_host
  before_validation :populate_title
  before_destroy :flush_page_cache

  validates_presence_of :host, :name, :title
  validates_uniqueness_of :host

  cattr_accessor :multi_sites_enabled, :cache_sweeper_logging

  class << self
    def find_by_host!(host)
      find_by_host(host) || raise(ActiveRecord::RecordNotFound, "Could not find site for hostname #{host}.")
    end

    # TODO how to make this an association or assoc extension so we can use it
    # in admin/users_controller?
    def find_users_and_superusers(id, options = {})
      condition = ["memberships.site_id = ? OR (memberships.site_id IS NULL AND roles.type = ?)", id, 'Role::Superuser']
      User.find :all, options.merge(:include => [:roles, :memberships], :conditions => condition)
    end
  end

  def multi_sites_enabled?
    self.class.multi_sites_enabled
  end

  def owner
    nil
  end

  def users_and_superusers(options = {})
    self.class.find_users_and_superusers id, options
  end

  def section_ids
    self.class.connection.select_values "SELECT id FROM sections WHERE site_id = #{id}"
  end

  # def tag_counts
  #   Content.tag_counts :conditions => "site_id = #{id}"
  # end

  def perma_host
    host.sub(':', '.')  # Needed to create valid directories in ms-win
  end

  def plugins
    @plugins ||= Plugins.new self, Engines.plugins
  end

  def spam_options=(options)
    if options.is_a? Hash
      options = options.deep_symbolize_keys
      options.deep_compact!{|key, value| value == '' }
    end
    write_attribute :spam_options, options
  end

  def spam_options(*keys)
    result = read_attribute(:spam_options) || {:default => {:ham => 'authenticated'}}
    keys.each do |key|
      return nil unless result.has_key?(key)
      result = result[key]
    end
    result
  end

  def spam_filter_active?(name)
    (spam_options[:filters] || []).include?(name)
  end

  def spam_engine
    @spam_engine ||= SpamEngine::FilterChain.assemble(self.spam_options)
  end

  private

    def downcase_host
      self.host = host.to_s.downcase
    end
    
    def replace_host_spaces
      self.host = host.to_s.gsub(/^\s+|\s+$/, '').gsub(/\s+/, '-')
    end
    
    # def permalinkaze_host
    #   self.host = PermalinkFu.escape(host)
    # end
    
    def populate_title
      self.title = self.name if self.title.blank?
    end

    def flush_page_cache
      # TODO this really belongs to the controller, remove the before_destroy hook

      # CachedPage.delete_all_by_site_id id
      # if page_cache_directory.to_s =~ /\/public$/
      #   # expire_pages CachedPage.find_all_by_site_id(@site.id)
      # else
      #   @site.cached_pages.delete_all
      #   page_cache_directory.rmtree rescue Errno::ENOENT
      # end
    end

  # before_validation :set_default_attributes
  # validates_presence_of :permalink_style, :search_path, :tag_path
  # validates_format_of     :search_path, :tag_path, :with => Format::STRING
  # validates_format_of     :host, :with => Format::DOMAIN
  # validates_uniqueness_of :host
  # validate :check_permalink_style
  #
  # after_create :setup_site_theme_directories
  # after_create { |site| site.sections.create(:name => 'Home') }
  # before_destroy :flush_cache_and_remove_site_directories

#   def import_theme(zip_file, name)
#     imported_name = Theme.import zip_file, :to => theme_path + name
#     @theme = @themes = @rollback_theme = nil
#     themes[imported_name]
#   end
#
#   def move_theme(theme, new_name)
#     FileUtils.move theme.base_path, theme_path + new_name
#   end
#
#   def search_url(query, page = nil)
#     "/#{search_path}?q=#{CGI::escapeHTML(query)}#{%(&amp;page=#{CGI::escapeHTML(page.to_s)}) unless page.blank?}"
#   end
#
#   def tag_url(*tags)
#     ['', tag_path, *tags.collect { |t| URI::escape(t.to_s) }] * '/'
#   end
#
#   def call_render(section, template_type, assigns = {}, controller = nil)
#     assigns.update('site' => to_liquid(section), 'mode' => template_type)
#     assigns.update(default_assigns) unless default_assigns.empty?
#     template = set_content_template(section, template_type)
#     layout = set_layout_template(section, template_type)
#     handler = @@template_handlers[theme.extension] || @@template_handlers[".liquid"]
#     handler.new(self).render(section, layout, template, assigns, controller)
#   end
#
#   def to_liquid(current_section = nil)
#     SiteDrop.new self, current_section
#   end
#

# #need non protected method for ErbTemplate - psq
#   def find_preferred_template(template_type, custom_template)
#     preferred = templates.find_preferred(template_type, custom_template)
#     return preferred if preferred && preferred.file?
#     raise MissingTemplateError.new(template_type, templates.collect_templates(template_type, custom_template).collect(&:basename))
#   end
#
#   protected
#     def set_default_attributes
#       self.permalink_style = ':year/:month/:day/:permalink' if permalink_style.blank?
#       self.search_path     = 'search' if search_path.blank?
#       self.tag_path        = 'tags'   if tag_path.blank?
#       [:permalink_style, :search_path, :tag_path].each { |a| send(a).downcase! }
#       self.timezone = 'UTC' if read_attribute(:timezone).blank?
#       if new_record?
#         self.approve_comments = false unless approve_comments?
#         self.comment_age      = 30    unless comment_age
#       end
#       true
#     end
#
#     def set_content_template(section, template_type)
#       preferred_template =
#         case template_type
#           when :page, :section
#             template_type = :single if template_type == :page
#             section.template
#           when :archive
#             section.archive_template
#         end
#       find_preferred_template(template_type, preferred_template)
#     end
#
#     def set_layout_template(section, template_type)
#       layout_template =
#         if section
#           section.layout
#         else
#           case template_type
#             when :tag    then tag_layout
#             when :search then sections.detect(&:home?).layout
#           end
#         end
#       find_preferred_template(:layout, layout_template)
#     end
#
#     private
#
#     def setup_site_theme_directories
#       begin
#         theme_path = "#{RAILS_ROOT}/themes/site-#{self.id}/simpla"
#         FileUtils.mkdir_p("#{RAILS_ROOT}/themes/site-#{self.id}")
#         FileUtils.cp_r("#{RAILS_ROOT}/themes/default", theme_path)
#         Dir[File.join(theme_path, '**/.svn')].each do |dir|
#           FileUtils.rm_rf dir
#         end
#       rescue
#         logger.error "ERROR: removing directories for site #{self.host}, check file permissions."
#         errors.add_to_base "Unable to create theme directories."
#         false
#       end
#     end

end
