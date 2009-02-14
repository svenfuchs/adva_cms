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
    end

    module Renderable
      def compile_with_dynamic_templates(local_assigns)
        if dynamic? and stale?
          expire_from_memory!
          mtime # memoizes the mtime
        end
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

    class Template
      def load!
        @cached = true
        # freeze # do not do this
      end

      def stale?
        # template is stale when the next request happens in the same second
        File.mtime(filename) >= mtime
      rescue Errno::ENOENT
        true
      end
    end
    
    # class DynamicEagerPath < Template::EagerPath
    #   extend ActiveSupport::Memoizable
    #   
    #   def initialize(path)
    #     super
    #     @dynamic = false
    #   end
    # 
    #   def [](path)
    #     # this is kinda expensive because stale? hits the disk on every lookup
    #     reload! if stale? 
    #     super
    #   end
    # 
    #   def reload!
    #     # only update stale templates and add/remove new/deleted ones
    #     initialize(path)
    #   end
    # 
    #   def stale?
    #     dynamic? and File.mtime(path) > mtime
    #   end
    #   
    #   def dynamic?
    #     @paths.values.first.try(:dynamic?)
    #   end
    # 
    #   def mtime
    #     File.mtime(path)
    #   end
    #   memoize :mtime
    # end
  end
end