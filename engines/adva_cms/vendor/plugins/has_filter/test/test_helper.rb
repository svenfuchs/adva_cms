$: << File.expand_path(File.dirname(__FILE__) + '/../lib')

require 'rubygems'
require 'active_record'
require 'active_support'
require 'active_support/test_case'

require 'mocha'
require File.dirname(__FILE__) + '/db/connect'

require 'has_filter'

class Person < ActiveRecord::Base
  has_filter :first_name, :last_name
end

Person.delete_all
Person.create! :first_name => 'John', :last_name => 'Doe'
Person.create! :first_name => 'Jane', :last_name => 'Doe'
Person.create! :first_name => 'Rick', :last_name => 'Roe'
 