# ActionView caches compiled templates as Ruby methods. We therefor need a 
# mechanism to expire these methods when a theme template has been edited.
#
# Thus we cache the time when the first template gets compiled and compare
# that to the mtime of the theme directory.
# 
# For this to work the theme directory needs to be touched manually when a 
# theme template file is edited.

unless ActionView::Template.method_defined?(:compile_times)
  module ActionView
    class Template
      cattr_accessor :compile_times
      @@compile_times = {}
    end
  
    module Renderable
      def recompile_with_check_theme_mtime?(symbol)
        expire_compiled_theme_templates! if theme_path and theme_modified_since_compile?
        recompile_without_check_theme_mtime?(symbol)
      end
      alias_method_chain :recompile?, :check_theme_mtime
    
      def compile_with_store_compile_times!(*args)
        compile_without_store_compile_times!(*args)
        self.class.compile_times[theme_path] ||= Time.now if theme_path
      end
      alias_method_chain :compile!, :store_compile_times

      def theme_modified_since_compile?
        compiled_at = compile_times[theme_path] || Time.now
        compiled_at < File.mtime("#{Theme.root_dir}/#{theme_path}") rescue false
      end
    
      # Tries to extract the theme path segment from a path like
      # public/themes/theme-1/templates/layouts/default.html.erb
      # Assumes that theme templates always are located in paths that have: 
      #   - a segment themes/ followed by 
      #   - an optional segment site-:id/ followed by
      #   - any arbitrary segment (the theme_id) and then followed by 
      #   - a segment templates/
      def theme_path
        try(:relative_path) =~ /\/(themes\/(site-\d+\/)?[^\/]+)\/templates/ and $1
      end

      def expire_compiled_theme_templates!
        # oh, yes, Rails escapes these method names like this
        method_segment = theme_path.to_s.gsub(/([^a-zA-Z0-9_])/) { $1.ord } 
        ActionView::Base::CompiledTemplates.instance_methods(false).each do |method|
          if method =~ /#{method_segment}/
            ActionView::Base::CompiledTemplates.send(:remove_method, method)
          end
        end unless method_segment.blank?
      end
    end
  end
end