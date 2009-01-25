require 'test_server/rails'

module TestServer
  class Server
    @@callbacks = {}
    
    class << self
      # too bad i can't use active_support/callbacks
      [:before_run, :after_run].each do |name| class_eval <<-code
          def #{name}(&block)
            @@callbacks[#{name.inspect}] ||= []
            @@callbacks[#{name.inspect}] << block
          end
        code
      end
    end
    
    attr_reader :argv
    
    def initialize(argv = [], options = {})
      @options = parse_opts(argv)
    end
    
    def run(argv, stderr, stdout, options = {})
      $stderr = stderr
      $stdout = stdout
      @argv = argv

      rails.reload_application
      run_callbacks(:before_run)

      runner = options[:runner] || 'Runner::TestUnit'
      if runner.respond_to?(:constantize)
        require runner.underscore # why doesn't dependencies do this for us?
        runner = runner.constantize
      end
      runner.run argv, stderr, stdout
      
      run_callbacks(:after_run)
      rails.cleanup_application
    end
    
    def start!
      puts "Ready"
      if @options[:daemon]
        daemonize!(@options[:pid], &exec_server)
      else
        exec_server.call
      end
    end
    
    def daemonize!(pid_file = nil, &block)
      return yield if $DEBUG
      pid = fork!(&block)
      puts "server launched. (PID: %d)" % pid
      File.open(pid_file,"w"){|f| f.puts pid } if pid_file
      exit! 0
    end
    
    def restart!
      puts "restarting"
      config = ::Config::CONFIG
      ruby = File::join(config['bindir'], config['ruby_install_name']) + config['EXEEXT']
      command_line = [ruby, $0, ARGV].flatten.join(' ')
      exec(command_line)
    end

    protected
      def rails
        @rails ||= TestServer::Rails.new
      end
    
      def parse_opts(argv)
        options = Hash.new
        opts = OptionParser.new
        opts.on("-d", "--daemon") {|v| options[:daemon] = true }
        opts.on("-p", "--pid PIDFILE"){|v| options[:pid] = v }
        opts.parse!(argv)
        options
      end

      def exec_server
        lambda {
          trap("USR2") { restart! } if Signal.list.has_key?("USR2")
          DRb.start_service("druby://127.0.0.1:8989", self)
          DRb.thread.join
        }
      end
      
      def fork!
        Process.fork{
          Process.setsid
          Dir.chdir(RAILS_ROOT)
          trap("SIGINT"){ exit! 0 }
          trap("SIGTERM"){ exit! 0 }
          trap("SIGHUP"){ restart! }
          File.open("/dev/null"){|f|
            STDERR.reopen f
            STDIN.reopen  f
            STDOUT.reopen f
          }
          yield
        }
      end
      
      def run_callbacks(name)
        (@@callbacks[name] || []).each do |block|
          instance_eval &block
        end
      end
  end
end