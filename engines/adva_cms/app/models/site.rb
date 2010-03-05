class Site < ActiveRecord::Base
  serialize :permissions
  serialize :spam_options

  has_many :sections, :dependent => :destroy, :order => :lft do
    def root
      Section.root(:site_id => proxy_owner.id)
    end

    def roots
      Section.roots(:site_id => proxy_owner.id)
    end

    def paths
      map(&:path)
    end

    # FIXME can this be on the nested_set?
    def update_paths!
      paths = Hash[*roots.map { |r|
        r.self_and_descendants.map { |n| [n.id, { 'path' => n.send(:build_path) }] } }.flatten]
      update paths.keys, paths.values
    end
  end

  has_many :users, :through => :memberships, :dependent => :destroy
  has_many :memberships, :dependent => :delete_all
  has_many :cached_pages, :dependent => :destroy, :order => 'cached_pages.updated_at desc'
  has_many :products

  belongs_to :account

  before_validation :downcase_host, :replace_host_spaces # c'mon, can't this be normalize_host or something?
  before_validation :populate_title
  before_validation :remove_host_slashes

  validates_presence_of :host, :name, :title
  validates_uniqueness_of :host
  validates_format_of :host, :with => /\A[a-z0-9-]+\z/

  cattr_accessor :multi_sites_enabled, :cache_sweeper_logging

  class << self

    def find_by_host!(host)
      site_host = host.split('.')[0]
      Site.find_by_host(site_host)
    end

    def find_users_and_superusers(id, account_id, options = {})
      condition = [
        %{
          memberships.site_id = ? OR
          (memberships.site_id IS NULL AND
          roles.name = ? AND
          roles.context_type = 'Account' AND
          roles.context_id = ?)
        }, id, 'superuser', account_id]
      User.find :all, options.merge(:include => [:roles, :memberships], :conditions => condition)
    end

  end


  def users_and_superusers(options = {})
    self.class.find_users_and_superusers id, account.id, options
  end

  def owners
    owner.owners << owner
  end

  def owner
    account
  end

  def published_newsletters
    self.newsletters.find(:all, :conditions => ['published = 1'])
  end

  def website_preview_link(host_with_port)
    if Rails.env == 'production'
      "http://#{host_with_port.sub(/www/, self.host)}"
    else
      "http://#{self.host}.#{host_with_port}"
    end
  end

  def multi_sites_enabled?
    self.class.multi_sites_enabled
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

  def email_from
    "#{name} <#{email}>" unless name.blank? || email.blank?
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

    def remove_host_slashes
      self.host = host.to_s.delete('/')
    end


end
