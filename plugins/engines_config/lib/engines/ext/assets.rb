# Makes Engines copy assets to the common assets subdirectories in public/,
# i.e. images/engine_name, javascripts/engine_name, stylesheets/engine_name

Engines.public_directory = "public"
Engines::Assets.class_eval do
    @@warning = %{Files in this directory are automatically generated from your plugins.
They are copied from the 'assets' directories of each plugin into this directory
each time Rails starts (script/server, script/console... and so on).
Any edits you make will NOT persist across the next server restart; instead you
should edit the files within the <plugin_name>/assets/ directory itself.}

  class << self
    def initialize_base_public_directory
      # nothing to do
    end
    
    # TODO add some flexibility to engines to allow for a scheme like this
    def mirror_files_for(plugin)
      return if !Engines.replicate_assets or plugin.public_directory.nil?
      begin
        %w(images javascripts stylesheets).each do |subdir|
          source = File.join(plugin.public_directory, subdir).gsub(RAILS_ROOT + '/', '')
          destination = File.join(Engines.public_directory, subdir, plugin.name)
          Engines.mirror_files_from(source, destination)
          if File.exist?(destination)
            warning = File.join(destination, "WARNING")
            File.open(warning, 'w') { |f| f.puts @@warning } unless File.exist?(warning)
          end
        end
        
      rescue Exception => e
        Engines.logger.warn "WARNING: Couldn't create the public file structure for plugin '#{plugin.name}'; Error follows:"
        Engines.logger.warn e
      end
    end
  end
end

module Engines
  # set this to either :request, :boot or false to control if and when Engines
  # replicates the asset subdirectories under the plugins's +assets+ (or +public+)
  # directory into the corresponding public directory.
  mattr_accessor :replicate_assets
  self.replicate_assets = :request
end

Engines::Plugin.class_eval do
  def load(initializer)
    return if loaded?
    super initializer
    add_plugin_view_paths
    case Engines.replicate_assets
    when :boot
      Engines::Assets.mirror_files_for(self)
    when :request
      require 'action_controller/dispatcher'
      ActionController::Dispatcher.to_prepare do
        Engines::Assets.mirror_files_for(self)
      end
    end
  end
end

