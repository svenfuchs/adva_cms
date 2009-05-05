test_app_dir    = '/tmp/adva_cms'
adva_cms_dir    = '/srv/integrity/builds/svenfuchs-adva_cms-master'
rails_dir       = '/srv/integrity/shared/rails/tags/v2.3.2'
start_time      = Time.now # Just for fun :)

def patch_file(path, after, insert)
  content = File.open(path) { |f| f.read }
  content.gsub!(after, "#{after}\n#{insert}") unless content =~ /#{Regexp.escape(insert)}/mi
  File.open(path, 'w') { |f| f.write(content) }
end

File.unlink 'public/index.html' rescue Errno::ENOENT

patch_file 'config/environment.rb',
  "require File.join(File.dirname(__FILE__), 'boot')",
  "require File.join(File.dirname(__FILE__), '../vendor/adva/engines/adva_cms/boot')"

puts "  - Symlinking adva-cms ..."

# WTF! Why this does not work with the variables?
run  "ln -s /srv/integrity/builds/svenfuchs-adva_cms-master/ /tmp/adva-cms/vendor/adva"

puts "  - Symlinking rails ..."

# WTF! Why this does not work with the variables?
run  "ln -s /srv/integrity/shared/rails/tags/v2.3.2/    /tmp/adva-cms/vendor/rails"

puts "  - Installing the engines and clonin test database ..."
rake "adva:install:all -R vendor/adva/engines/adva_cms/lib/tasks"
rake "adva:assets:install"
rake "db:test:clone"

end_time = (Time.now - start_time).to_i
puts  "  - Rails app setup time was #{end_time} seconds."