require 'optparse'

OptionParser.new do |o|
  o.on('-l', '--line=LINE', "Run tests defined at the given LINE.") do |line|
    With.options[:line] = line
  end
  
  o.on('-p', '--prepare-database', "Do not initialize fixtures to the database.") do |line|
    DO_PREPARE_DATABASE = true
  end
  
  o.on('-w', '--with=ASPECTS', "Run tests defined for the given ASPECTS (comma separated).") do |aspects|
    With.aspects += aspects.split(/,/).map(&:to_sym)
  end
end.parse!(ARGV)

DO_PREPARE_DATABASE = false unless defined?(DO_PREPARE_DATABASE)

