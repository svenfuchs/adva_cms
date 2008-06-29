ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/story'
require 'spec/rails/story_adapter'
require 'active_record/fixtures'

Spec::Runner.configure do |config|
  config.include Spec::Story
end

include FactoriesAndWorkers::Factory

def factories(*names)
  names.each do |name|
    require File.expand_path(File.dirname(__FILE__) + "/factories/#{name}")
  end
end

def steps(*names)
  names.each do |name|
    require File.expand_path(File.dirname(__FILE__) + "/steps/#{name}")
  end
end