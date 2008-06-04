if "test" == RAILS_ENV
  
  ActiveRecord::Base.class_eval do
    class << self
      alias_method :old_add_observer, :add_observer
      def add_observer(o); end
    end
    
    extend NoPeepingToms
  end
  
end
