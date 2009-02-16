module Rails 
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

      def option_definitions
        @option_definitions ||= {}
      end

      def option(name, default, type = :string)
        define_option_accessors(name, default)
        option_definitions[name.to_sym] = { :default => default, :type => type }
      end

      def options=(options)
        # FIXME symbolize_keys and slice defined options
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
      
        def define_option_accessors(name, default)
          raise "can't use #{name.inspect} as an option name" if respond_to? name
          instance_eval <<-END, __FILE__, __LINE__
            def #{name}
              config.options[#{name.inspect}] || #{default.inspect}
            end
            def #{name}=(value)
              config.options[#{name.inspect}] = value
            end
          END
        end

        def config
          @config ||= begin
            raise 'undefined @owner for plugin config' unless @owner
            Config.find_by_name_and_owner_type_and_owner_id(self.name, @owner.class.name, @owner.id) ||
            Config.new(:name => self.name, :owner => @owner)
          end
        end
    end
  end
end

Rails::Plugin.send :include, Rails::Plugin::Configurable