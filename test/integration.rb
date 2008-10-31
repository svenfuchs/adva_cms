Dir[File.expand_path(File.dirname(__FILE__) + '/integration/**/*_test.rb')].each do |path|
  require path
end