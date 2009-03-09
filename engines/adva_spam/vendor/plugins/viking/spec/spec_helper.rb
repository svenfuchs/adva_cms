begin
  require 'spec'
rescue LoadError
  require 'rubygems'
  gem 'rspec'
  require 'spec'
end

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'viking'

# See http://blog.jayfields.com/2007/11/ruby-testing-private-methods.html
class Class
  def publicize_methods(instance=nil)
    saved_protected_instance_methods = self.protected_instance_methods
    self.class_eval { public *saved_protected_instance_methods }
    yield(instance)
  ensure
    self.class_eval { protected *saved_protected_instance_methods }
  end
end

##
# rSpec Hash additions.
#
# From 
#   * http://wincent.com/knowledge-base/Fixtures_considered_harmful%3F
#   * Neil Rahilly
class Hash
  ##
  # Filter keys out of a Hash.
  #
  #   { :a => 1, :b => 2, :c => 3 }.except(:a)
  #   => { :b => 2, :c => 3 }
  def except(*keys)
    self.reject { |k,v| keys.include?(k || k.to_sym) }
  end

  ##
  # Override some keys.
  #
  #   { :a => 1, :b => 2, :c => 3 }.with(:a => 4)
  #   => { :a => 4, :b => 2, :c => 3 }
  def with(overrides = {})
    self.merge overrides
  end

  ##
  # Returns a Hash with only the pairs identified by +keys+.
  #
  #   { :a => 1, :b => 2, :c => 3 }.only(:a)
  #   => { :a => 1 }
  def only(*keys)
    self.reject { |k,v| !keys.include?(k || k.to_sym) }
  end
end