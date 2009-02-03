module ActiveRecord
  module HasManyThemes
    def self.included(base)
      base.extend ActMacro
    end

    module ActMacro
      def has_many_themes(options = {})
        return if has_many_themes?

        has_many :themes, :dependent => :delete_all do
          def active
            find(:all, :conditions => 'active = 1')
          end
        end
        
        include InstanceMethods # FIXME instead, check for the association being present
      end

      def has_many_themes?
        included_modules.include?(ActiveRecord::HasManyThemes::InstanceMethods)
      end
    end

    module InstanceMethods
    end
  end
end

ActiveRecord::Base.send :include, ActiveRecord::HasManyThemes