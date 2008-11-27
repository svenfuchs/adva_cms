# load factories
dir = File.dirname(__FILE__) + '/factories'
Dir[dir + '/**/*.rb'].sort.each{|path| require path }
