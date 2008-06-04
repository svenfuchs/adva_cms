$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../../rails/actionpack/lib/'
require 'action_controller'
require 'action_controller/test_process'

$LOAD_PATH << File.dirname(__FILE__) + '/../lib/'
require 'routing_filter'
require 'routing_filter/base'
require 'routing_filter/locale'
require File.dirname(__FILE__) + '/root_section.rb'

class Section
  def self.types
    []
  end
  def to_param
    1
  end
end
