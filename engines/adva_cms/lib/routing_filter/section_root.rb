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
    
    # This implementation looks for a section_id param in the args hash, which seems a bit brittle.
    # def around_generate(*args, &block)
    #   returning yield do |result|
    #     if result !~ %r(^/admin/) and root = site_root(args) and result =~ generate_pattern(root)
    #       result.sub! $2, $3 unless $3 == '.'
    #       result.replace '/' if result.empty?
    #     end
    #   end
    # end

    def around_generate(*args, &block)
      returning yield do |result|
        if result !~ %r(^/admin/) and result =~ generate_pattern
          segments, section_type, section_id, dot_or_dash = $2, $3, $4, $5
          section = Section.find(section_id.to_i)
          if section and section.root_section?
            result.sub! segments, dot_or_dash unless dot_or_dash == '.'
            result.replace '/' if result.empty?
          end
        end
      end
    end
    
    protected
    
      def recognize_pattern
        @recognize || %r(^/?(/[\w]{2})?(/articles|/event|/pages|/boards|/topics|/photos|/categories|/sets|/tags|/\d{4}|\.|/?$))
      end
    
      def generate_pattern
        types = Section.types.map{|type| type.downcase.pluralize }.join('|')
        %r(^(/[\w]{2})?(/(#{types})/([\d]+)(\.|/|$)))
      end
    
      def find_root_by_host(env)
        site = Site.find_by_host(env[:host_with_port])
        site.sections.root if site
      end
      
      # def generate_pattern(root)
      #   %r(^(/[\w]{2})?(/(?:#{root.type.pluralize.downcase}|sections)/#{root.id}(\.|/|$)))
      # end
      
      # def site_root(args)
      #   args = args.reverse.detect {|arg| arg.is_a?(Hash) && arg[:section_id] } or return nil
      #   section = args[:section_id] 
      #   section = Section.find(section) unless section.is_a?(Section)
      #   section.site.sections.root
      # end
    
      # def current_root
      #   Site.find(Thread.current[:site_id]).sections.root if Thread.current[:site_id]
      # end
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
