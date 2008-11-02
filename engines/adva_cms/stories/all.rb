dir = File.dirname(__FILE__)
Dir[File.expand_path("#{dir}/stories/**/*.rb")].uniq.each do |file|
  require file
end