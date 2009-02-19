TEST_DIR        = '/tmp/adva_cms'
TEST_ADVA_DIR   = TEST_DIR + '/vendor/adva'
CC_DIR          = '/srv/cruise/projects/adva-cms/work'
start_time      = Time.now # Just for fun :)

def patch_file(path, after, insert)
  content = File.open(path) { |f| f.read }
  content.gsub!(after, "#{after}\n#{insert}") unless content =~ /#{Regexp.escape(insert)}/mi
  File.open(path, 'w') { |f| f.write(content) }
end

File.unlink 'public/index.html' rescue Errno::ENOENT

rakefile("adva-cms.rake") do
  <<-src
    require 'tasks/rails'
    load 'vendor/adva/engines/adva_cms/lib/tasks/adva_cms.rake'
  src
end

file 'script/test-adva-cms', <<-src
  #!/usr/bin/env ruby
  paths = ARGV.clone
  load 'vendor/adva/script/test'
src

patch_file 'config/environment.rb',
  "require File.join(File.dirname(__FILE__), 'boot')",
  "require File.join(File.dirname(__FILE__), '../vendor/adva/engines/adva_cms/boot')"

run "cp -r #{CC_DIR} #{TEST_ADVA_DIR}"

rake  "rails:freeze:gems"
run   "patch -p0 < vendor/adva/patch-2.3/rails-2.3.patch"

rake  "db:migrate:prepare"
run   "rake db:migrate"
rake  "db:test:clone"

end_time = (Time.now - start_time).to_i
puts  "Rails app setup, time elapsed #{end_time} seconds."
