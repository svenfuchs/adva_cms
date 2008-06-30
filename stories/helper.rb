ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/story'
require 'spec/mocks'
require 'spec/rails/story_adapter'
require 'active_record/fixtures'

Spec::Runner.configure do |config|
  config.include Spec::Story
end

include FactoriesAndWorkers::Factory

now = Time.parse '2008-01-01 12:00:00 UTC'
Time.stub!(:now).and_return now
Time.zone.stub!(:now).and_return now

def factories(*names)
  names.each do |name|
    require File.expand_path(File.dirname(__FILE__) + "/factories/#{name}")
  end
end

def steps(*names)
  step_dir = File.expand_path(File.dirname(__FILE__) + '/steps')
  if names.first == :all
    Dir["#{step_dir}/**/*.rb"].uniq.map do |path|
      require path
      File.basename(path).gsub(/#{File.extname(path)}$/, '').to_sym
    end
  else
    names.each{|name| require step_dir + "/#{name}" }
  end
end