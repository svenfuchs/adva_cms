# require "#{File.dirname(__FILE__)}/vendor/plugins/cells/boot"
require "#{File.dirname(__FILE__)}/lib/rails_ext/railties/plugin"

Rails::Configuration.class_eval do
  # needs to be here because we otherwise wouldn't have a good scope for
  # globbing for plugin config/environment files
  def default_plugin_paths
    paths = ["#{root_path}/vendor/plugins"] # "#{root_path}/vendor/adva/engines", "#{root_path}/vendor/adva/plugins"
    paths << "#{root_path}/vendor/adva/test" if ENV['RAILS_ENV'] == 'test'
    paths
  end

  # Rails' GemDependency makes it remarkably hard to extend and add any custom 
  # behaviour. What we'd probably want is: check our plugin's vendor/gems directory
  # and use shipped gem if the gem is not vendored in vendor/gems and not installed 
  # on the system. The following implementation does that except that it does 
  # not check for vendor/gems. Any takers?
  def plugin_gem(name, options = {})
    lib, version = options.values_at(:lib, :version)
    begin
      Kernel.send :gem, name, version
    rescue Gem::LoadError
      dir = File.dirname(caller.first.split(':').first)
      $: << File.expand_path("#{dir}/../vendor/gems/#{name}-#{version.gsub(/[^\d\.]*/, '')}/lib")
    end
    require(lib || name)
  end
end

Rails::Initializer.class_eval do
  class << self
    def run_with_plugin_environments(command = :process, configuration = Rails::Configuration.new, &block)
      Rails.configuration = configuration
      load_plugin_environments
      run_without_plugin_environments(command, configuration, &block)
    end
    alias :run_without_plugin_environments :run
    alias :run :run_with_plugin_environments

    def configure
      yield Rails.configuration
    end

    protected

      def load_plugin_environments
        paths = Dir["{#{Rails.configuration.plugin_paths.join(',')}}/*/config/environment.rb"]
        paths.each { |path| require path }
      end
  end
end

# Rails::GemDependency does not allow to freeze gems anywhere else than vendor/gems
# So we hook up our own directories ...
#
# TODO how to improve this?

# gem_dir = "#{RAILS_ROOT}/vendor/adva/gems"
# Dir[gem_dir + '/*'].each{|dir| $:.unshift dir + '/lib'}
# 
# require 'zip/zip'
# # require 'cronedit'
# require 'activerecord' # paperclip needs activerecord to be present
# require 'paperclip'
