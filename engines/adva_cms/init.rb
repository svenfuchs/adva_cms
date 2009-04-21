require 'paperclip' 

require 'adva_config'
require 'extensible_forms'
require 'time_hacks'
require 'core_ext'
require 'rails_ext'
require 'cells_ext'

# require 'menu'
require 'event'    # need to force these to be loaded now, so Rails won't
require 'registry' # reload them between requests (FIXME ... this doesn't seem to happen?)

# ExtensibleFormBuilder.default_class_names(:field_set) << 'clearfix' # sigh

config.to_prepare do
  Registry.set :redirect, {
    :login        => lambda {|c| c.send :admin_sites_path },
    :verify       => '/',
    :site_deleted => lambda {|c| c.send :admin_sites_path }
  }
end

I18n.load_path += Dir[File.dirname(__FILE__) + '/locale/**/*.yml']

# register_javascript_expansion \
#   :common  => %w( adva_cms/prototype adva_cms/lowpro adva_cms/flash 
#                   adva_cms/cookie adva_cms/json ),
#   :default => %w( adva_cms/parseuri adva_cms/roles adva_cms/application ),
#   :login   => %w( ),
#   :simple  => %w( ),
#   :admin   => %w( adva_cms/effects adva_cms/dragdrop adva_cms/sortable_tree/sortable_tree
#                   adva_cms/admin/smart_form adva_cms/admin/spotlight 
#                   adva_cms/admin/sortable_tree adva_cms/admin/sortable_list
#                   adva_cms/admin/admin adva_cms/admin/article adva_cms/admin/tabs )

register_javascript_expansion \
  :common => %w( adva_cms/jquery adva_cms/jquery-lowpro adva_cms/jquery-ui adva_cms/jquery.common
                 adva_cms/json adva_cms/cookie adva_cms/jquery.flash ),
  :login => %w(),
  :default => %w( adva_cms/jquery.roles adva_cms/jquery.dates adva_cms/parseuri adva_cms/application ),
  :simple => %w(),
  :admin => %w( adva_cms/admin/admin adva_cms/admin/jquery.article adva_cms/admin/jquery.cached_pages )

register_stylesheet_expansion \
  :default => %w( adva_cms/default adva_cms/common adva_cms/forms ),
  :login   => %w( adva_cms/admin/reset adva_cms/admin/common adva_cms/admin/forms 
                  adva_cms/layout/login ),
  :simple  => %w( adva_cms/reset adva_cms/admin/common adva_cms/admin/forms 
                  adva_cms/layout/simple ),
  :admin   => %w( adva_cms/reset adva_cms/admin/layout adva_cms/admin/common
                  adva_cms/admin/header adva_cms/admin/sidebar adva_cms/admin/forms 
                  adva_cms/admin/lists adva_cms/admin/content adva_cms/admin/themes
                  adva_cms/admin/users adva_cms/jquery/jquery-ui )
