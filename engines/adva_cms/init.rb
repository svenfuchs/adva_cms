# remove plugin from load_once_paths
ActiveSupport::Dependencies.load_once_paths -= ActiveSupport::Dependencies.load_once_paths.select{|path| path =~ %r(^#{File.dirname(__FILE__)}) }

require 'redcloth'

require 'adva_config'
require 'time_hacks'
require 'core_ext'
require 'rails_ext'
require 'cells_ext'

require 'routing'
require 'roles'

require 'event'    # need to force these to be loaded now, so Rails won't
require 'registry' # reload them between requests (FIXME ... this doesn't seem to happen?)

config.to_prepare do
  Registry.set :redirect, {
    :login        => lambda {|c| c.send :admin_sites_path },
    :verify       => '/',
    :site_deleted => lambda {|c| c.send :admin_sites_path }
  }

  class Cell::Base
    class_inheritable_accessor :states
    self.states = []

    class << self
      def inherited(child)
        child.send(:define_method, :current_action) { state_name.to_sym }
        super
      end

      def has_state(state)
        self.states << state.to_sym unless self.states.include?(state.to_sym)
      end

      # convert a cell to xml
      def to_xml(options={})
        options[:root]    ||= 'cell'
        options[:indent]  ||= 2
        options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])

        cell_name = self.to_s.gsub('Cell', '').underscore

        options[:builder].tag!(options[:root]) do |cell_node|
          cell_node.id   cell_name
          cell_node.name I18n.translate(:"adva.cells.#{cell_name}.name", :default => cell_name.humanize)
          cell_node.states do |states_node|
            self.states.uniq.each do |state|
              states_node.state do |state_node|
                state = state.to_s

                # render the form ... if it's empty ... well, then it's empty ;-)
                # view = Cell::View.new
                # template = self.find_class_view_for_state(state + '_form').each do |path|
                #   puts path
                #   if template = view.try_picking_template_for_path(path)
                #     puts template
                #     return template
                #   end
                # end
                # form = template ? ERB.new(view.render(:template => template)).result : ''

                # FIXME: this implementation is brittle at best and needs to be refactored/corrected ASAP!!!
                possible_templates = Dir[RAILS_ROOT + "/app/cells/#{cell_name}/#{state}_form.html.erb"] + Dir[File.join(RAILS_ROOT, 'vendor', 'adva', 'engines') + "/*/app/cells/#{cell_name}/#{state}_form.html.erb"]
                template = possible_templates.first
                form = template ? ERB.new(File.read(template)).result : ''

                state_node.id          state
                state_node.name        I18n.translate(:"adva.cells.#{cell_name}.states.#{state}.name", :default => state.humanize)
                state_node.description I18n.translate(:"adva.cells.#{cell_name}.states.#{state}.description", :default => '')
                state_node.form        form
              end
            end
          end
        end
      end
    end

    extend CacheReferences::PageCaching::ActMacro

    delegate :site, :section, :perform_caching, :to => :controller

    def render_state(state)
      @cell = self
      self.state_name = state

      content = dispatch_state(state)

      return content if content.kind_of? String

      render
    end

    def render
      render_view_for_state(state_name)
    end
  end
end

# uncomment this to have Engines copy assets to the public directory on
# every request (default: copies on server startup)
# Engines.replicate_assets = :request

I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

# turn this on to get detailed cache sweeper logging in production mode
# Site.cache_sweeper_logging = true

TagList.delimiter = ' '
Tag.destroy_unused = true
Tag.class_eval do def to_param; name end end

XssTerminate.untaint_after_find = true

# patch acts_as_versioned to play nice with xss_terminate
config.to_prepare do
  ActiveRecord::Base.class_eval do
    class << self
      unless method_defined?(:acts_as_versioned_without_filters_attributes)
        alias :acts_as_versioned_without_filters_attributes :acts_as_versioned
        def acts_as_versioned(*args)
          acts_as_versioned_without_filters_attributes(*args)
          versioned_class.filters_attributes :none => true
        end
      end
    end
  end
end

# make javascript_expansions and stylesheet_expansions accessible
# (after commit http://github.com/rails/rails/commit/104898fcb7958bcb69ba0239d6de8aa37f2da9ba) -> Rails 2.3
# ActionView::Helpers::AssetTagHelper.module_eval { mattr_accessor :javascript_expansions, :stylesheet_expansions }

# register two additional JavaScript expansions and two CSS expansions
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :adva_cms_common => [
    'adva_cms/prototype', 'adva_cms/effects',
    'adva_cms/lowpro', 'adva_cms/flash',
    'adva_cms/cookie', 'adva_cms/json'
  ],
  :adva_cms_public => [
    'adva_cms/parseuri', 'adva_cms/roles',
    'adva_cms/application'
  ],
  :adva_cms_admin => [
    'adva_cms/dragdrop', 'adva_cms/sortable_tree/sortable_tree',
    'adva_cms/admin/admin.js', 'adva_cms/admin/article.js',
    'adva_cms/admin/smart_form.js', 'adva_cms/admin/sortable_tree.js',
    'adva_cms/admin/sortable_list.js', 'adva_cms/admin/spotlight.js'
  ])
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :adva_cms_public => [
    'adva_cms/default', 'adva_cms/common',
    'adva_cms/forms'
  ],
  :adva_cms_admin => [
    'adva_cms/admin/form', 'adva_cms/admin/lists',
    'adva_cms/admin/sortable_tree', 'adva_cms/admin/themes',
    'adva_cms/admin/users', 'adva_cms/admin/widgets'
  ]
)