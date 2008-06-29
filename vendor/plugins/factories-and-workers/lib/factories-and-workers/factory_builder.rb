require 'digest/sha1'

module FactoriesAndWorkers

  module Factory
    def self.included( base )
      base.extend ClassMethods          
    end
    
    module ClassMethods
      def factory( kind, default_attrs, opts={}, &block )
        FactoryBuilder.new( kind, default_attrs, opts, self, &block )
      end

      # creates a random hex string, converts it to hexatridecimal, and truncates to desired length (max 30)
      def uniq len=10
        Digest::SHA1.hexdigest("#{rand(1<<64)}/#{Time.now.to_f}/#{Process.pid}").to_i(16).to_s(36)[1..len]
      end

      @@factory_counter = Hash.new(0)
      def increment! counter
        @@factory_counter[ counter.to_s ] += 1
      end

      @@factory_initializers = {}
      def factory_initializers
        @@factory_initializers
      end
    end

    # factory methods are defined as class methods; this delegation will allow them to also be called as instance methods
    def method_missing method, *args
      if self.class.respond_to?( method )
        self.class.send method, *args
      else
        super
      end
    end

  end

  class FactoryBuilder
    def initialize( factory, default_attrs, opts, from_klass, &block )
      raise ArgumentError, ":chain must be a lambda block!" if opts[:chain] && !opts[:chain].is_a?( Proc )
      opts.reverse_merge!( :class => factory )
      
      ar_klass = ActiveRecord.const_get( opts[:class].to_s.classify )
      from_klass.factory_initializers[ factory ] = block if block_given?

      # make the valid attributes method      
      valid_attrs_method = :"valid_#{factory}_attributes"
      Factory::ClassMethods.send :define_method, valid_attrs_method do |*args|
        action         = args.first.is_a?( TrueClass ) ? :create : :build
        attrs          = default_attrs.symbolize_keys
        attr_overrides = args.extract_options!
        attrs.merge!( attr_overrides.symbolize_keys ) if attr_overrides
        attrs.reverse_merge!( opts[:chain].call ) if opts[:chain]
        attrs.each_pair do |key, value|
          if attr_overrides.keys.include?(:"#{key}_id")
            attrs.delete(key)   # if :#{model}_id is overridden, then remove :#{model} and don't evaluate the lambda block
          else
            attrs[key] = case value
            when Proc
              value.call               # evaluate lambda blocks
            when :belongs_to_model
              send( :"#{action}_#{key}" )  # create or build model dependencies, if none are found in the db
            when String                # interpolate magic variables
              value.gsub( /\$UNIQ\((\d+)\)/ ){ from_klass.uniq( $1.to_i ) }.  
              gsub( '$COUNT', from_klass.increment!( :"#{ar_klass}_#{key}" ).to_s )
            else
              value
            end
          end
        end
      end       

      # make the valid attribute method, which only fetches a single attribute
      valid_attr_method  = :"valid_#{factory}_attribute"
      Factory::ClassMethods.send :define_method, valid_attr_method do |arg|
        return unless arg.is_a?( Symbol )
        base = default_attrs.dup
        base.reverse_merge!( opts[:chain].call ) if opts[:chain]
        returning base[ arg ] do |value|
          value = value.call if value.is_a?( Proc )            # evaluate lambda if needed
        end
      end

      # alias default_*_attributes to valid_*_attributes, for semantic equivalency
      Factory::ClassMethods.send :alias_method, valid_attrs_method.to_s.gsub('valid','default').to_sym, valid_attrs_method
      Factory::ClassMethods.send :alias_method,  valid_attr_method.to_s.gsub('valid','default').to_sym, valid_attr_method


      after_initialize_block = from_klass.factory_initializers[ factory ]

      # make the create method
      Factory::ClassMethods.send :define_method, :"create_#{factory}" do |*args|
        ar_klass.create!( self.send( valid_attrs_method, true, args.first ) ) do |obj|
          after_initialize_block.call( obj ) if after_initialize_block
        end
      end

      # make the build method
      Factory::ClassMethods.send :define_method, :"build_#{factory}" do |*args|
        ar_klass.new( self.send( valid_attrs_method, false, args.first ) ) do |obj|
          after_initialize_block.call( obj ) if after_initialize_block
        end
      end

    end #initialize
  end

end
