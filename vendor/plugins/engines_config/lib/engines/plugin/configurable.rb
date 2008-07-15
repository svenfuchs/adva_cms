# TODO make this use has_options?

module Engines
  class Plugin
    module Configurable
      class Config < ActiveRecord::Base  
        set_table_name 'plugin_configs'
        serialize :options, Hash
        belongs_to :owner, :polymorphic => true
    
        def after_initialize
          write_attribute(:options, {}) if read_attribute(:options).nil?
        end
      end
      
      attr_accessor :owner
    
      def configurable?
        not default_options.empty?
      end
  
      def default_options
        @default_options ||= {}
      end
 
      def option(name, default, type = :string)
        raise "can't use #{name.inspect} as an option name" if respond_to? name
        instance_eval <<-END, __FILE__, __LINE__
          def #{name}
            config.options[#{name.inspect}] || #{default.inspect}
          end      
          def #{name}=(value)
            config.options[#{name.inspect}] = value
          end
        END
        default_options[name] = {:default => default, :type => type}
      end
  
      def options=(options)
        config.options = options
      end
      
      def id
        name
      end
      
      def to_param
        name
      end
      
      def save!
        config.save!        
      end
      
      def destroy
        config.destroy
        @config = nil
      end
      
      private
  
      def config
        @config ||= begin
          Config.find_by_name_and_owner_type_and_owner_id(conf_name, @owner.class.name, @owner.id) ||
          Config.new(:name => conf_name, :owner => @owner)
        end
      end
      
      # allow subclasses to hook in here
      def conf_name
        name
      end
    end
  end
end
 
