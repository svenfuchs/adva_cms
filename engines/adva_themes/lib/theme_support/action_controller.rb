module ThemeSupport
  module ActionController
    def self.included(base)
      base.class_eval do
        extend ActMacro
        delegate :acts_as_themed_controller?, :to => "self.class"
      end
    end

    module ActMacro
      def acts_as_themed_controller(options = {})
        return if acts_as_themed_controller?
        include InstanceMethods

        before_filter :add_theme_view_paths
        
        write_inheritable_attribute :force_template_types, options[:force_template_types] || []
        write_inheritable_attribute :current_themes, options[:current_themes] || []
      end

      def acts_as_themed_controller?
        included_modules.include?(ThemeSupport::ActionController::InstanceMethods)
      end
    end

    module InstanceMethods
      [:force_template_types, :current_themes].each do |name|
        module_eval <<-eoc, __FILE__, __LINE__
          def #{name}
            @#{name} ||= case accessor = self.class.read_inheritable_attribute(:#{name}) || :#{name}
              when Symbol then send(accessor)
              when Proc   then accessor.call(self)
              else accessor
            end
          end
        eoc
      end

      def add_theme_view_paths
        if respond_to? :current_theme_paths
          paths = current_theme_paths.map{|path| "#{path}/templates" }
          prepend_view_path(paths) unless paths.empty?
        end
      end

      def current_theme_paths
        current_themes ? current_themes.map{|theme| theme.path.to_s } : []
      end

      def authorize_template_extension!(template, ext)
        return if allowed_template_type?(ext)
        raise ThemeSupport::TemplateTypeError.new(template, force_template_types)
      end

      def allowed_template_type?(ext)
        force_template_types.blank? || force_template_types.include?(ext)
      end
    end
  end
end

ActionController::Base.send :include, ThemeSupport::ActionController

class ActionController::Base
  def self.reset_file_exist_cache!
    @@file_exist_cache = nil
  end
end

class ActionView::Base
  def self.reset_file_exist_cache!
    @@file_exist_cache = nil
  end
end
