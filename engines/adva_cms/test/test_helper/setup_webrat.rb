require 'webrat'
require 'webrat/rails'

Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end

