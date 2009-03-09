$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

## Load core extensions
Dir[File.join(File.dirname(__FILE__), 'core_ext', '*.rb')].each do |core_ext|
  require(core_ext)
end

## Let's get this party started
require 'viking/viking'
require 'viking/version'