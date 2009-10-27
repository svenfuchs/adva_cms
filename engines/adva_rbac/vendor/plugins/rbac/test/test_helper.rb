$: << File.dirname(__FILE__) + '/../lib'

require 'rubygems'
require 'activerecord'
require 'activesupport'
require 'test/unit'
require 'rbac'

require 'rbac/role_type/static'
require 'rbac/role_type/active_record'

require File.dirname(__FILE__) + '/database'
require File.dirname(__FILE__) + '/static'

Dir[File.dirname(__FILE__) + '/tests/*.rb'].each do |filename|
  require filename
end


class Test::Unit::TestCase
  def self.test(name, &block)
    define_method("test: " + name, &block)
  end

  def with_default_permissions(permissions_map={}, &block)
    original_permissions = Rbac::Context.default_permissions
    Rbac::Context.default_permissions = permissions_map
    yield
    Rbac::Context.default_permissions = original_permissions
  end
  
  protected
  
    def method_missing(method, *args)
      return Rbac::RoleType.build(method.to_s.gsub(/_type/, '')) if method.to_s =~ /_type$/
      return ::User.find_by_name(method.to_s) if user_names.include?(method.to_s)
      return ::Group.find_by_name(method.to_s) if group_names.include?(method.to_s)
      super
    end
    
    def user_names
      @user_names ||= User.all.map(&:name)
    end
    
    def group_names
      @group_names ||= Group.all.map(&:name)
    end

    def blog
      ::Section.find_by_title('blog')
    end
    
    def content
      ::Content.find_by_title('content')
    end
end

module TestHelper
  def self.test(name, &block)
    define_method("test: " + name, &block)
  end
end