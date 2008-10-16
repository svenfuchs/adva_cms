# load factories
factories_dir = File.dirname(__FILE__) + '/factories'
Dir[factories_dir + '/*.rb'].sort.each do |factory_file|
  require factory_file
end