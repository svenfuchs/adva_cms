# TODO is there a cleaner way to do this? Site will be reloaded for each
# request in dev mode so this needs to be reloaded, too.

require 'action_controller/dispatcher'
ActionController::Dispatcher.to_prepare do
  # Enable if you want to host multiple sites on this app
  Site.multi_sites_enabled = true
end

# For page caching to work in multi_sites mode you have to configure your
# front-end server accordingly, so it can look for cached pages before
# passing the request to Rails.
#
# See http://blog.hasmanythrough.com/2008/1/30/segregated-page-cache-storage
# for tips regarding ngix setup