TEST_DIR   = '/tmp/adva_cms'
CC_DIR     = '/srv/cruise/projects/adva-cms/work'
RAILS_DIR  = '/srv/cruise/shared/rails'
start_time = Time.now # Just for fun :)

def patch_file(path, after, insert)
  content = File.open(path) { |f| f.read }
  content.gsub!(after, "#{after}\n#{insert}") unless content =~ /#{Regexp.escape(insert)}/mi
  File.open(path, 'w') { |f| f.write(content) }
end

File.unlink 'public/index.html' rescue Errno::ENOENT

file 'script/test-adva-cms', <<-src
  #!/usr/bin/env ruby
  paths = ARGV.clone
  load 'vendor/adva/script/test'
src

patch_file 'config/environment.rb',
  "require File.join(File.dirname(__FILE__), 'boot')",
  "require File.join(File.dirname(__FILE__), '../vendor/adva/engines/adva_cms/boot')"

run "ln -s #{CC_DIR} #{TEST_DIR}/vendor/adva"
# run "ln -s #{RAILS_DIR} #{TEST_DIR}/vendor/rails"
# rake  "rails:freeze:gems"
# run   "patch -p0 < vendor/adva/patch-2.3/rails-2.3.patch"

rake "db:migrate"
rake "db:test:clone"

end_time = (Time.now - start_time).to_i
puts  "Rails app setup, time elapsed #{end_time} seconds."
