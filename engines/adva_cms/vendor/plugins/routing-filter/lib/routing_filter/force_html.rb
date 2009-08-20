require 'routing_filter/base'

module RoutingFilter
  class ForceHtml < Base
    def around_recognize(path, env, &block)
      # remove the extension from the path
      path.gsub! /\.html$/, '' unless path =~ %r(^/admin)
      yield(path, env)
    end

    def around_generate(*args, &block)
      returning yield do |result|
        result = result.first if result.is_a?(Array)
        # append the extension to the path unless it has a known extension
        unless result =~ %r(^/admin) or result.blank? or root?(result)
          extensions = Mime::EXTENSION_LOOKUP.keys
          result.replace(result.sub(/(\?|$)/, '.html\1')) unless result =~ /\.#{extensions.join('|')}(\?|$)/
        end
      end
    end

    def root?(url_or_path)
      !!(url_or_path =~ %r(^(http.?://[^/]+)?\/?$))
    end
  end
end

# TODO implement routing_filter spec:
#
# def root?(url_or_path)
#   !!(url_or_path =~ %r(^(http.?://[^/]+)?\/?$))
# end
#
# paths = %w(
#   http://adva-cms.org/signup
#   http://adva-cms.org/
#   http://adva-cms.org
#   /
# ) << ''
#
# paths.each do |path|
#   p root?(path)
# end