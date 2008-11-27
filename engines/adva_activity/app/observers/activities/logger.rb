module Activities
  class Logger < ActiveRecord::Observer
    class_inheritable_accessor :activity_attributes, :activity_conditions
    self.activity_attributes = []
    self.activity_conditions = [[:created, :new_record?], [:deleted, :frozen?]]

    class << self
      def logs_activity(options = {})
        self.activity_attributes += options[:attributes] if options[:attributes]
        yield Configurator.new(self) if block_given?
      end
    end

    class Configurator
      def initialize(klass)
        @klass = klass
      end

      def method_missing(name, options)
        options.assert_valid_keys :if
        @klass.activity_conditions << [name, options[:if]]
      end
    end

    def before_save(record)
      prepare_activity_logging(record)
    end

    def after_save(record)
      log_activity(record)
    end

    def after_destroy(record)
      prepare_activity_logging(record)
      log_activity(record)
    end

    protected

    def prepare_activity_logging(record)
      record.instance_variable_set :@activity, initialize_activity(record)
    end

    def log_activity(record)
      activity = record.instance_variable_get :@activity
      if activity && !activity.actions.empty?
        activity.object = record
        activity.author = record.author if record.respond_to? :author
        activity.save!
      end
      record.instance_variable_set :@activity, nil
    end

    def initialize_activity(record)
      Activity.new :actions => collect_actions(record),
                   :object_attributes => collect_activity_attributes(record)
    end

    def collect_actions(record)
      activity_conditions.collect do |name, conditions|
        name.to_s if conditions_satisfied?(record, conditions)
      end.compact
    end

    def conditions_satisfied?(record, conditions)
      conditions = conditions.is_a?(Array) ? conditions : [conditions]
      conditions.collect do |condition|
        condition_satisfied?(record, condition)
      end.inject(true){|a, b| a && b }
    end

    def condition_satisfied?(record, condition)
      case condition
      when Symbol then !!record.send(condition)
      when Hash then
        condition.collect do |key, condition|
          case key
          when :not then !record.send(condition)
          else raise 'not implemented' # TODO: should this be NotImplementedError?
          end
        end.inject(false){|a, b| a || b }
      end
    end

    def collect_activity_attributes(record)
      Hash[*activity_attributes.map do |attribute|
        [attribute.to_s, case attribute
                         when Symbol then record.send attribute
                         when Proc   then record.attribute.call(self)
                         end]
      end.flatten]
    end
  end
end