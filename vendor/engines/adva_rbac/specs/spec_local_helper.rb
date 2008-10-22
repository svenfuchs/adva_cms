# does not include environment.rb

require 'rubygems'

$:.unshift File.expand_path(File.dirname(__FILE__) + "/../../../plugins/rspec/lib")
require 'active_support'
require 'active_record'
require 'spec'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/db/database.yml'))
config['test']['database'] = File.dirname(__FILE__) + "/#{config['test']['database']}"

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/log/debug.log")
ActiveRecord::Base.configurations = config
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations['test'])
ActiveRecord::Base.silence do
  ActiveRecord::Migration.verbose = false
  load(File.dirname(__FILE__) + "/db/schema.rb")
end

plugin_dir = File.expand_path(File.dirname(__FILE__) + '/../')
$:.unshift plugin_dir + "/lib"
require plugin_dir + '/init.rb'

require File.expand_path(File.dirname(__FILE__) + '/mocks')
require File.expand_path(File.dirname(__FILE__) + '/spec_role_helper')

class RbacContextExampleGroup < Spec::Example::ExampleGroup
  before :each do
    @account = Account.new
    @site = Site.new :account => @account
    @section = Section.new :site => @site
    @content = Content.new :section => @section
    
    @site_2 = Site.new :account => @account
    @section_2 = Section.new :site => @site_2
    
    @other_account = Account.new
    @other_site = Site.new :account => @other_account
    @other_section = Section.new :site => @other_site
    @other_content = Content.new :section => @other_section    

    @user = User.new :account => @account
  end
end
Spec::Example::ExampleGroupFactory.register(:rbac_context, RbacContextExampleGroup)

class RbacRoleExampleGroup < RbacContextExampleGroup
  after :each do
    Rbac::Role.constants.each do |name|
      Rbac::Role.send :remove_const, name unless name == "Base"
    end
    Rbac::Role::Base.children = []
  end
  
  def include_role(name, options = {})
    role = Rbac::Role.build name, options
    simple_matcher do |given, matcher|
      msg = "the role #{name}" + (options[:context] ? " in the context of #{options[:context]}" : '')
      matcher.description = "includes #{msg}"
      matcher.failure_message = "expected #{given} to include #{msg}"
      matcher.negative_failure_message = "expected #{given} not to include #{msg}"
      given.include? role
    end
  end
  
  def have_role(name, options = {})
    simple_matcher do |given, matcher|
      msg = "role #{name.inspect}" + (options[:context] ? " in the context of #{options[:context]}" : '')
      matcher.description = "has the #{msg}"
      matcher.failure_message = "expected #{given} to have #{msg}"
      matcher.negative_failure_message = "expected #{given} not to have #{msg}"
      given.has_role? name, options
    end
  end
end
Spec::Example::ExampleGroupFactory.register(:rbac_role, RbacRoleExampleGroup)