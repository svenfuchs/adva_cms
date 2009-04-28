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

rake 'adva:install:core -R vendor/adva/engines/adva_cms/lib/tasks'

puts <<-end

Thanks for installing adva-cms!

We've performed the following tasks:

* created a fresh Rails app
* cloned adva-cms to vendor/adva
* installed adva-cms' core engines to vendor/plugins
* installed adva-cms' images, javascripts, stylesheets to public/

You can now do:

cd #{File.basename(@root)}
ruby script/server
open http://localhost:3000

You should see adva-cms installation screen. 
Fill out the form and you're started, enjoy!

end