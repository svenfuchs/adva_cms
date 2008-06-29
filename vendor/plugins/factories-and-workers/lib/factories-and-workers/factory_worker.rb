module FactoriesAndWorkers

  module Worker
    def worker( worker_name )
      FactoryWorker.find_and_work worker_name
    end

    def self.included( base )
      base.extend ClassMethods
    end

    module ClassMethods
      def factory_worker( worker, &block )
        FactoryWorker.new( worker, &block )
      end
    end

  end

  class FactoryWorker
    @@workers = HashWithIndifferentAccess.new

    def initialize( worker, &block )
      case worker
      when Hash
        @dependencies = [ *worker.values.first ]
        @worker = worker.keys.first
      when Symbol, String
        @worker = worker
      else
        raise ArgumentError, "I don't know how to make a factory worker out of '#{worker.inspect}'"
      end

      @block = block if block_given?
      @@workers[ @worker ] = self
    end

    def self.find_and_work( worker_name )
      raise ArgumentError, "There is no factory worker named '#{worker_name.to_s}' available" unless @@workers.include?(worker_name.to_s)
      @@workers[ worker_name ].work
    end

    def work
      @dependencies.each{ |w| self.class.find_and_work( w ) } if @dependencies
      surface_errors{ @block.call( self ) } if @block
    end

    def surface_errors
      yield
    rescue Object => error
      puts 
      puts "There was an error working the factory worker '#{@worker}':", error.inspect
      puts 
      puts error.backtrace
      puts 
      exit!
    end
  end

end