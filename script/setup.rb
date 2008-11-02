rails_root = File.expand_path(File.dirname(__FILE__) + '/../../..')

def patch_file(path, after, insert)
  content = File.open(path){|f| f.read }
  content.gsub!(after, "#{after}\n#{insert}") unless content =~ /#{insert}/
  File.open(path, 'w'){|f| f.write(content) }
end

patch_file rails_root + '/config/environment.rb',
           "require File.join(File.dirname(__FILE__), 'boot')",
           "require File.join(File.dirname(__FILE__), '../vendor/adva/engines/adva_cms/boot')"

patch_file rails_root + '/config/routes.rb',
           "ActionController::Routing::Routes.draw do |map|",
           "\tmap.from_plugins\n"
           
patch_file rails_root + '/Rakefile',
           "require 'tasks/rails'",
           "\nload 'vendor/adva/plugins/engines/tasks/engines.rake'"
           