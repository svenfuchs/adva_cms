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

git :clone => 'git://github.com/svenfuchs/adva_cms.git vendor/adva # this might take a bit, grab a coffee meanwhile :)'

inside('vendor/adva') do
  run 'git checkout -b tag/0.1.2 0.1.2'
end

rake 'adva:install:core -R vendor/adva/engines/adva_cms/lib/tasks'
