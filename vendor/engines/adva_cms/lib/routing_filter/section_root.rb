require 'routing_filter/base'

module RoutingFilter
  class SectionRoot < Base
    # prepends the root section path to the path if the given pattern matches
    def around_recognize(path, env, &block)
      if path !~ %r(^/admin) and root = find_root_by_host(env)
        path.sub! recognize_pattern do
          "#{$1}/#{root.type.pluralize.downcase}/#{root.id}#{$2}"
        end
      end
      yield
    end

    def around_generate(*args, &block)
      returning yield do |result|
        if result !~ %r(^/admin/) and root = current_root and result =~ generate_pattern(root)
          result.sub! $2, $3 unless $3 == '.'
          result.replace '/' if result.empty?
        end
      end
    end
    
    protected
    
      def recognize_pattern
        @recognize || %r(^/?(/[\w]{2})?(/articles|/pages|/boards|/topics|/categories|/tags|/\d{4}|\.|/?$))
      end
    
      def generate_pattern(root)
        %r(^(/[\w]{2})?(/(?:#{root.type.pluralize.downcase}|sections)/#{root.id}(\.|/|$)))
      end
      
      def find_root_by_host(env)
        site = Site.find_by_host(env[:host_with_port])
        site.sections.root if site
      end
    
      def current_root
        Thread.current[:site].sections.root if Thread.current[:site]
      end
  end
end

# This pattern matches a path that starts (aside from an optional locale) with 
# a single slash or one of articles|pages|categories|tags, 4 digits or a dot
# followed by anything.
#
# %r(^/?(/[\w]{2})?(/articles|/pages|/boards|/topics|/categories|/tags|/\d{4}|\.|/?$))
#
# So all of the following paths will match:
# / and /de
# /articles and /de/articles (same with pages, categories, tags)
# /2008 and /de/2008
# /.rss and /de.rss
