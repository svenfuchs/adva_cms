namespace :db do
  task :migrate => [:environment, 'db:migrate:prepare', 'db:migrate:original_migrate', 'db:migrate:cleanup'] do
    # nothing :)
  end

  namespace :migrate do
    task :original_migrate do
      ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
      ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
      Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
    end

    task :cleanup do
      target = "#{Rails.root}/db/migrate"
      files = Dir["#{target}/*.rb"]
      unless files.empty?
        FileUtils.rm files
        puts "removed #{files.size} migrations from db/migrate"
      end
      files = Dir["#{target}/app/*.rb"]
      unless files.empty?
        FileUtils.cp files, target
        puts "copied #{files.size} migrations back to db/migrate"
      end
      FileUtils.rm_rf "#{target}/app"
    end

    desc "Copy migrations from plugins to db/migrate"
    task :prepare do
      target = "#{Rails.root}/db/migrate/"

      # first copy all app migrations away
      files = Dir["#{target}*.rb"]

      unless files.empty?
        FileUtils.mkdir_p "#{target}app/"
        FileUtils.cp files, "#{target}app/"
        puts "copied #{files.size} migrations to db/migrate/app"
      end

      dirs = Rails.plugins.values.map(&:directory)
      files = Dir["{#{dirs.join(',')}}/db/migrate/*.rb"]
      
      unless files.empty?
        FileUtils.mkdir_p target
        FileUtils.cp files, target
        puts "copied #{files.size} migrations to db/migrate"
      end
    end
  end
end

namespace :assets do
  desc "Copy public assets from plugins to public/"
  task :copy do
    require 'config/environment'

    target = "#{Rails.root}/public/"
    sources = Dir["{#{Rails.configuration.plugin_paths.join(',')}}/**/public/*"]

    FileUtils.mkdir_p(target) unless File.directory?(target)
    FileUtils.cp_r sources, target
  end
end