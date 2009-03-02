class Site < ActiveRecord::Base
  serialize :permissions
  serialize :spam_options

  has_many :sections, :dependent => :destroy, :order => :lft, :conditions => ['type IN (?)', Section.types] do
    def root
      find_by_parent_id nil, :order => 'lft'
    end

    # def roots
    #   nested_set_class.find_with_nested_set_scope(:all, :conditions => "(#{nested_set_parent} IS NULL)", :order => "#{nested_set_left}")
    # end

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
  has_many :cached_pages, :dependent => :destroy, :order => 'cached_pages.updated_at desc'

  before_validation :downcase_host, :replace_host_spaces # c'mon, can't this be normalize_host or something?
  before_validation :populate_title

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
    types = Section.types.map { |type| "'#{type}'" }.join(', ')
    self.class.connection.select_values("SELECT id FROM contents WHERE type IN (#{types}) AND site_id = #{id}")
  end

  # def tag_counts
  #   Content.tag_counts :conditions => "site_id = #{id}"
  # end

  def perma_host
    host.sub(':', '.')  # Needed to create valid directories in ms-win
  end

  def plugins
    @plugins ||= Rails.plugins.values.inject(ActiveSupport::OrderedHash.new) do |plugins, plugin|
      plugin = plugin.clone
      plugin.owner = self
      plugins[plugin.name.to_sym] = plugin
      plugins
    end
  end

  private

    def downcase_host
      self.host = host.to_s.downcase
    end

    def replace_host_spaces # err ... maybe name this a tad less implementation oriented?
      self.host = host.to_s.gsub(/^\s+|\s+$/, '').gsub(/\s+/, '-')
    end

    def populate_title
      self.title = self.name if self.title.blank?
    end
end
