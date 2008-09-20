paths = ARGV.clone
require File.dirname(__FILE__) + "/helper"

paths = paths.map do |path|
  path = File.expand_path(path)
  File.directory?(path) ? Dir["#{path}/**/*.txt"].uniq : Dir[path]
end.flatten

paths.each do |path|
  with_steps_for *steps(:all) do
    run path, :type => RailsStory
  end
end