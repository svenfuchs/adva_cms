require 'webrat'
require 'webrat/rails'

Webrat.configure do |config|
  config.application_environment = :test # needed by webrat < 0.4.4
  config.mode = ENV["WEBRAT_MODE"] == "selenium" ? :selenium : :rails
  config.open_error_files = false
end

