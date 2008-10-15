$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../../../../vendor/plugins/rspec/lib"))
require 'spec'
require 'spec/rake/spectask'

desc "Run all specs"
Spec::Rake::SpecTask.new("adva_cms:test:specs") do |t|
  t.spec_opts = ["--colour", "--format progress", "--loadby mtime", "--reverse"]
  t.spec_files = File.expand_path(File.dirname(__FILE__) + "/../../../engines/*/spec/{controllers,helpers,models,views}/**/*spec.rb")
end

namespace :adva_cms do
  desc "Run all specs and stories"
  task :test => ["test:specs", "test:stories"]

  namespace :test do
    desc "Run all stories"
    task :stories do
      stories_path = File.expand_path(File.dirname(__FILE__) + "/../../stories")
      ruby stories_path + "/run.rb stories"
      #require stories_path + '/helper.rb'

      #Dir["#{stories_path}/steps/*.rb"].each do |step_file|
      #  require step_file
      #end

      #Dir["#{stories_path}/**/*.txt"].each do |story_file|
      #  with_steps_for(*steps(:all)) do
      #    run story_file, :type => RailsStory
      #  end
      #end
    end
  end
end