def patch_file(path, current, insert, options = {})
  options = {
    :patch_mode => :insert_after
  }.merge(options)

  old_text = current
  new_text = patch_string(current, insert, options[:patch_mode])

  content = File.open(path) { |f| f.read }
  content.gsub!(old_text, new_text) unless content =~ /#{Regexp.escape(insert)}/mi
  File.open(path, 'w') { |f| f.write(content) }
end

def patch_string(current, insert, mode = :insert_after)
  case mode
  when :change
    "#{insert}"
  when :insert_after
    "#{current}\n#{insert}"
  when :insert_before
    "#{insert}\n#{current}"
  else
    patch_string(current, insert, :insert_after)
  end
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

patch_file 'config/initializers/new_rails_defaults.rb',
  "ActionController::Routing.generate_best_match = false",
  "ActionController::Routing.generate_best_match = true",
  :patch_mode => :change

patch_file 'config/initializers/new_rails_defaults.rb',
  "ActionController::Routing.generate_best_match = true",
  "# You *must* use Rails' old routing recognition/generation mode in order for adva-cms to work correctly
#ActionController::Routing.generate_best_match = false",
  :patch_mode => :insert_before

git :clone => 'git://github.com/svenfuchs/adva_cms.git vendor/adva # this might take a bit, grab a coffee meanwhile :)'

inside('vendor/adva') do
  run 'git checkout -b tag/0.3.1 0.3.1'
end

rake 'adva:install:core -R vendor/adva/engines/adva_cms/lib/tasks'
rake 'adva:assets:install'

puts <<-end

Thanks for installing adva-cms!

We've performed the following tasks:

* created a fresh Rails app
* cloned adva-cms to vendor/adva
* patched config/environment.rb and config/initializers/new_rails_defaults.rb
* installed adva-cms' core engines to vendor/plugins
* installed adva-cms' images, javascripts, stylesheets to public/

You can now do:

cd #{File.basename(@root)}
ruby script/server
open http://localhost:3000

You should see adva-cms installation screen.
Fill out the form and you're started, enjoy!

end
