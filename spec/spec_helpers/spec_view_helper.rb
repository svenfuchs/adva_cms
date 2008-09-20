module SpecViewHelper
  class << self
    def included(base)
      base.send :include, Stubby
      base.send :include, ResourcePathHelper
      base.send :include, ViewExampleGroupMethods
    end
  end

  module ViewExampleGroupMethods
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def acting_block
        @acting_block || parent.acting_block
      end

      def act!(&block)
        @acting_block = block
      end
    end

    def acting(&block)
      act!
      block.call(response) if block
      response
    end
    alias :result :acting

    def act!
      instance_eval &self.class.acting_block
    end
  end
end