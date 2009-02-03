require 'test/unit'
require 'test/unit/testresult'
require 'test_server/runner/redgreen'
Test::Unit.run = true

module TestServer
  module Runner
    class TestUnit
      class << self
        def run(argv = ARGV, stderr = STDERR, stdout = STDOUT)
          $stdout = stdout
          $stderr = stderr
          
          # pattern = parse_opts(argv)[:pattern]
          # pattern ||= argv.first
          pattern = argv.first || 'test/**/*_test.rb'
          
          Dir[pattern].each { |file| Kernel.load file }
          
          Test::Unit::AutoRunner.run
        end
        
        protected
    
          def parse_opts(argv)
            options = { :pattern => 'test/**/*_test.rb' }
            opts = OptionParser.new do |o|
              o.on("-p", "--pattern [PATTERN]") { |p| options[:pattern] = p }
            end.parse!(argv)
            options
          end
      end
    end
  end
end