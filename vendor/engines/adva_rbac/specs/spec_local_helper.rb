# does not include environment.rb

require 'rubygems'

$:.unshift File.expand_path(File.dirname(__FILE__) + "/../../../plugins/rspec/lib")
require 'active_support'
require 'spec'

module ActiveRecord; class Base; end; end

plugin_dir = File.expand_path(File.dirname(__FILE__) + '/../')
$:.unshift plugin_dir + "/lib"
require plugin_dir + '/init.rb'

require File.expand_path(File.dirname(__FILE__) + '/mocks')

class RbacContextExampleGroup < Spec::Example::ExampleGroup
  before :each do
    @account = Account.new
    @site = Site.new @account
    @section = Section.new @site
    @content = Content.new @section
    
    @site_2 = Site.new @account
    @section_2 = Section.new @site_2
    
    @other_account = Account.new
    @other_site = Site.new @other_account
    @other_section = Section.new @other_site
    @other_content = Content.new @other_section    

    @user = User.new 
  end
end
Spec::Example::ExampleGroupFactory.register(:rbac_context, RbacContextExampleGroup)

class RbacRoleExampleGroup < RbacContextExampleGroup
  after :each do
    Rbac::Role.constants.each do |name|
      Rbac::Role.send :remove_const, name unless name == "Base"
    end
  end
  
  def include_role(name, options = {})
    role = Rbac::Role.build name, options
    simple_matcher do |given, matcher|
      msg = "the role #{name}" + (options[:context] ? " in the context of #{options[:context]}" : '')
      matcher.description = "includes #{msg}"
      matcher.failure_message = "expected #{given.inspect} to include #{msg}"
      matcher.negative_failure_message = "expected #{given.inspect} not to include #{msg}"
      given.include? role
    end
  end
  
  def have_role(name, options = {})
    simple_matcher do |given, matcher|
      msg = "role #{name.inspect}" + (options[:context] ? " in the context of #{options[:context]}" : '')
      matcher.description = "has the #{msg}"
      matcher.failure_message = "expected #{given.inspect} to have #{msg}"
      matcher.negative_failure_message = "expected #{given.inspect} not to have #{msg}"
      given.has_role? name, options
    end
  end
end
Spec::Example::ExampleGroupFactory.register(:rbac_role, RbacRoleExampleGroup)