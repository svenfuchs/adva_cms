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
        result = result.first if result.is_a?(Array)
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
        @recognize || %r(^/?(/[\w]{2})?(/articles|/event|/wikipages|/boards|/topics|/photos|/categories|/sets|/tags|/\d{4}|\.|/?$))
      end
    
      def generate_pattern
        types = Section.types.map{|type| type.downcase.pluralize }.join('|')
        %r(^(/[\w]{2})?(/(#{types})/([\d]+)(\.|/|$)))
      end
    
      def find_root_by_host(env)
        site = Site.find_by_host!(env[:host_with_port])
        site.sections.root if site
      end
  end
end