# If the path is, aside from a slash and an optional locale, the leftmost part
# of the path, replace it by "sections/:id" segments.

module RoutingFilter
  class SectionPaths < Base
    def around_recognize(path, env, &block)
      site = Site.find_by_host!(env[:host_with_port])
      paths = paths_for_site(site)
      if path !~ %r(^/([\w]{2,4}/)?admin) and !paths.empty? and path =~ recognize_pattern(paths)
        if section = section_by_path(site, $2)
          type = section.type.pluralize.downcase
          path.sub! %r(^/([\w]{2,4}/)?(#{paths})(?=/|\.|$)), "/#{$1}#{type}/#{section.id}#{$3}"
        end
      end
      yield
    end

    def around_generate(*args, &block)
      returning yield do |result| 
        result = result.first if result.is_a?(Array)
        if result !~ %r(^/([\w]{2,4}/)?admin) and result =~ generate_pattern
          section = Section.find $2.to_i
          result.sub! "#{$1}/#{$2}", "#{section.path}#{$3}"
        end
      end
    end
    
    protected
      def paths_for_site(site)
        site ? site.sections.paths.sort{|a, b| b.size <=> a.size }.join('|') : []
      end
      
      def section_by_path(site, path)
        site.sections.detect{|section| section.path == path }
      end
    
      def recognize_pattern(paths)
        %r(^/([\w]{2,4}/)?(#{paths})(?=/|\.|$))
      end
      
      def generate_pattern
        types = Section.types.map{|type| type.downcase.pluralize }.join('|')
        %r((#{types})/([\d]+(/?))(\.?)) # ?(?=\b)?
      end
  end
end
