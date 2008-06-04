namespace :spec do
  namespace :link do
    desc 'Remove plugin spec file links from main spec dir.'
    task :clear => :environment do |task, args|
      puts "Removing all spec links from spec/"        
      root = Pathname.new RAILS_ROOT
      pattern = "#{root}/spec/{controllers,fixtures,helpers,models,views}/**/*spec.rb"
      Pathname.glob(pattern).each do |file|
        file.unlink if file.symlink?
      end
    end
    
    desc 'Link spec files from all plugin spec dirs to main spec dir.'
    task :all => :environment do |task, args|
      Rake::Task['spec:link'].invoke Engines.plugins.map(&:name).join(',')
    end       
  end

  desc 'Link spec files from specified plugin(s) spec dirs to main spec dir. (usage: rake spec:plugins:link[plugin-1,plugin-2])'
  task({:link => :environment}, :name, :version) do |task, args|
    name = args[:name] || ENV['NAME']
    name.split(',').each do |name|
      if plugin = Engines.plugins[name]
        pattern = "#{plugin.directory}/spec/{controllers,fixtures,helpers,models,views}/**/*spec.rb"
        sources = Pathname.glob(pattern)
        unless sources.empty?
          puts "Linking specs from #{plugin.directory.sub(RAILS_ROOT, '')}/spec to spec/"        
          sources.each do |source|
            target = Pathname.new "#{RAILS_ROOT}#{source.sub(plugin.directory, '')}"
            FileUtils.mkdir_p(target.dirname) unless target.dirname.exist?
            FileUtils.ln_s source.realpath, target unless target.exist?
          end
        end
      else
        puts "Plugin #{name} does not exist."
      end
    end
  end
end