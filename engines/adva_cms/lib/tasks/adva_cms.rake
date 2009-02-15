namespace :db do
  namespace :migrate do
    desc "Copy migrations from plugins to db/migrate"
    task :prepare do
      require 'config/environment'
      
      target = "#{Rails.root}/db/migrate/"
      files = Dir["{#{Rails.configuration.plugin_paths.join(',')}}/**/db/migrate/*.rb"]
      
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