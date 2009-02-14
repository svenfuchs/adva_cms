# ActionView caches compiled templates as Ruby methods. We therefor need a
# mechanism to expire these methods when a theme template has been edited.

unless ActionView::Template.method_defined?(:compile_times)
  module ActionView
    class Base
      module CompiledTemplates
        def self.flush_methods(pattern)
          instance_methods(false).each { |m| remove_method(m) if m =~ /#{pattern}/}
        end
      end

      def view_paths
        @view_paths.update! # what's the best place to check for stale paths?
        @view_paths
      end
    end
    
    class PathSet
      def update!
        #select(&:stale?).each(&:update!)
        each(&:update!)
      end
    end

    class Template
      class EagerPath # changed so that we can update if dynamic templates have changed
        extend ActiveSupport::Memoizable
        
        def initialize(path)
          super
          update!
          @dynamic = false
        end

        def add(template)
          template.load!
          template.accessible_paths.each do |path| 
            @paths[path] = template
          end
        end

        def remove(template)
          template.accessible_paths.each { |path| @paths.delete(path) }
        end

        def update!
          @paths = {}
          # maybe only update stale templates and add/remove new/deleted ones
          templates_in_path { |template| add(template) }
        end

        def stale?
          dynamic? and File.mtime(path) >= mtime
        end
        
        def dynamic?
          !@paths.empty? and @paths.values.first.dynamic?
        end

        def mtime
          File.mtime(path)
        end
        memoize :mtime
      end

      cattr_accessor :compile_times
      @@compile_times = {}

      def load!
        @cached = true
        # freeze # gotta overwrite this to keep Template from freezing itself
      end

      def stale?
        # gotta overwrite this so that the template is stale when the next
        # request happens in the same second
        File.mtime(filename) >= mtime
      rescue Errno::ENOENT
        true
      end
    end

    module Renderable
      def compile_with_dynamic_templates(local_assigns)
        expire_from_memory! if dynamic? and stale?
        compile_without_dynamic_templates(local_assigns)
      end
      alias_method_chain :compile, :dynamic_templates

      def dynamic?
        !!relative_path.match(/\/(themes\/(site-\d+\/)?[^\/]+)\/templates/)
      end
      # memoize :dynamic?

      def expire_from_memory!
        ActionView::Base::CompiledTemplates.flush_methods(method_segment)
        flush_cache :source, :compiled_source, :mtime
      end
    end
  end
end
