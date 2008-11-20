# $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../../../../vendor/plugins/rspec/lib"))
# require 'spec'
# require 'spec/rake/spectask'
# 
# desc "Run all specs"
# Spec::Rake::SpecTask.new("adva_cms:test:specs") do |t|
#   t.spec_opts = ["--colour", "--format progress", "--loadby mtime", "--reverse"]
#   t.spec_files = File.expand_path(File.dirname(__FILE__) + "/../../../engines/*/spec/{controllers,helpers,models,views}/**/*spec.rb")
# end
# 
# namespace :adva_cms do
#   desc "Run all specs and stories"
#   task :test => ["test:specs", "test:stories"]
# 
#   namespace :test do
#     desc "Run all stories"
#     task :stories do
#       stories_path = File.expand_path(File.dirname(__FILE__) + "/../../stories")
#       ruby stories_path + "/run.rb stories"
#       #require stories_path + '/helper.rb'
# 
#       #Dir["#{stories_path}/steps/*.rb"].each do |step_file|
#       #  require step_file
#       #end
# 
#       #Dir["#{stories_path}/**/*.txt"].each do |story_file|
#       #  with_steps_for(*steps(:all)) do
#       #    run story_file, :type => RailsStory
#       #  end
#       #end
#     end
#   end
# end

namespace :adva_cms do
  desc "Migrate database and plugins to current status with preserved order."
  task :migrate do |task, args|
    require 'config/environment'
    # collect all migration files from app and plugins and sort them based on their id/timestamp
    locations = ["db/migrate"] + Engines.plugins.collect { |plugin| plugin.migration_directory }
    migration_files = locations.collect { |location| Dir["#{location}/*.rb"] }.flatten.sort { |x, y| File.basename(x) <=> File.basename(y) }

    # execute them in order
    migration_files.each do |file|
      # only migrate to the relevant version
      version = file.scan(/([0-9]+)_([_a-z0-9]*).rb/).first.first
      ActiveRecord::Migrator.migrate(File.dirname(file), version.to_i)
    end
  end
end