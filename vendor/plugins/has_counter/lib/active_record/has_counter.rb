module ActiveRecord
  module HasCounter
    class << self
      def included(base)
        base.extend ActMacro
      end
    end
    
    module ActMacro
      def has_counter(*names)
        options = names.extract_options!
        names.each do |name|
          counter_name = :"#{name}_counter"
        
          define_method :"#{name}_count" do
            send(counter_name).count
          end
        
          has_one counter_name, :as => :owner, 
                                :class_name => 'Counter', 
                                :conditions => "name = '#{name}'", 
                                :dependent => :delete
        
          after_create do |forum|
            counter = Counter.create! :owner => forum, :name => name.to_s
          end
        
          # Wires up the counted class so that it updates our counter
          owner_name = options[:as] || self.name.underscore
          name.to_s.classify.constantize.class_eval do
            after_create do |record|
              record.send(owner_name).send(counter_name).increment! 
            end          
            after_destroy do |record|
              record.send(owner_name).send(counter_name).decrement!
            end
          end
        end
      end
    end
  end
end

