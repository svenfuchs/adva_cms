config_path = File.expand_path(File.dirname(__FILE__) + '/../../..//config')

def patch_file(path, after, insert)
  content = File.open(path){|f| f.read }
  content.gsub!(after, "#{after}\n#{insert}") unless content =~ /#{insert}/
  File.open(path, 'w'){|f| f.write(content) }
end

patch_file config_path + '/environment.rb',
           "require File.join(File.dirname(__FILE__), 'boot')",
           "require File.join(File.dirname(__FILE__), '../vendor/adva/engines/adva_cms/boot')"

patch_file config_path + '/routes.rb',
           "ActionController::Routing::Routes.draw do |map|",
           "\tmap.from_plugins\n"
