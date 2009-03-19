namespace :adva do
  namespace :install do
    desc 'install adva_cms core engines'
    task :core do
      ENV['engines'] = %w(adva_activity adva_blog adva_cms adva_comments adva_rbac adva_user).join(',')
      Rake::Task['adva:install'].invoke
    end

    desc 'install all adva_cms engines and plugins'
    task :all do
      ENV['engines'] = 'all'
      ENV['plugins'] = 'all'
      Rake::Task['adva:install'].invoke
    end
  end

  namespace :uninstall do
    desc 'uninstall adva_cms core engines'
    task :core do
      ENV['engines'] = %w(adva_activity adva_blog adva_cms adva_comments adva_rbac adva_user).join(',')
      Rake::Task['adva:uninstall'].invoke
    end

    desc 'uninstall all adva_cms engines and plugins'
    task :all do
      ENV['engines'] = 'all'
      ENV['plugins'] = 'all'
      Rake::Task['adva:uninstall'].invoke
    end
  end

  desc 'install selected adva_cms engines (pick some with engines=all plugins=all or engines=name1,name2 plugins=name3)'
  task :install do
    perform(:install)
    Rake::Task['db:migrate'].invoke
    Rake::Task['adva:assets:copy'].invoke
  end

  desc 'uninstall selected adva_cms engines (pick some with engines=all plugins=all or engines=name1,name2 plugins=name3)'
  task :uninstall do
    perform(:uninstall)
  end

  namespace :assets do
    desc "Copy public assets from plugins to public/"
    task :copy do
      target = "#{Rails.root}/public/"
      sources = Dir["vendor/plugins/{*,*/**}/public/*"]

      FileUtils.mkdir_p(target) unless File.directory?(target)
      FileUtils.cp_r sources, target
      puts "copying assets to public ..."
    end
  end

  def perform(method)
    except = ENV['except'] ? ENV['except'].split(',') : []
    core = %w(adva_activity adva_blog adva_cms adva_comments adva_rbac adva_user)

    %w(engines plugins).each do |type|
      if ENV[type]
        names = ENV[type] == 'all' ? all(type) : ENV[type].split(',')
        names -= core if ENV[type] == 'all' && method == :uninstall
        names -= except
        unless ENV[type].nil?
          puts "#{method}ing #{type}: #{names.join(', ')}"
          send(method, type, names)
        end
      end
    end
  end

  def install(type, plugins)
    FileUtils.mkdir_p(target) unless File.exists?(target)
    sources = plugins.map { |engine| source(type, engine) }

    if Rake.application.unix?
      FileUtils.ln_s sources, target, :force => true
    elsif Rake.application.windows?
      FileUtils.cp_r sources, target
    else
      raise 'unknown system plattform'
    end
  end

  def uninstall(type, plugins)
    plugins.each do |plugin|
      FileUtils.rm_r "#{target}/#{plugin}" rescue Errno::ENOENT
    end
  end

  def all(type)
    Dir["#{source(type)}/*"].map { |path| File.basename(path) }
  end

  def rails_root
    @rails_root ||= Rake.application.find_rakefile_location.last
  end

  def source(type, subdir = nil)
    "#{rails_root}/vendor/adva/#{type}" + (subdir ? "/#{subdir}" : '')
  end

  def target
    "#{rails_root}/vendor/plugins"
  end
end

namespace :db do
  task :migrate => [:environment, 'db:migrate:prepare', 'db:migrate:original_migrate', 'db:migrate:cleanup'] do
    # there's nothing else to do ...
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
