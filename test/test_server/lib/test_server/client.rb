module TestServer
  class Client
    class << self
      def run(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        options = {:runner => 'TestServer::Runner::TestUnit'}.merge(options)

        argv, stderr, stdout = *args
        argv ||= ARGV
        stderr ||= STDERR
        stdout ||= STDOUT

        begin
          DRb.start_service
          server = DRbObject.new_with_uri("druby://127.0.0.1:8989")
          server.run(argv, stderr, stdout, options)
        rescue DRb::DRbConnError => e
          # options.error_stream.puts "No server is running"
          puts "No server is running"
        end
      end
    end
  end
end