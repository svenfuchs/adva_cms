Dir[File.expand_path(File.dirname(__FILE__) + '/integration/**/*')].each do |path|
  require path
end