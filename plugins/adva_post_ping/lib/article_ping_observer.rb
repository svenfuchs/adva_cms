require 'thread'

class ArticlePingObserver < ActionController::Caching::Sweeper
  observe Article
  SERVICES = []

  def after_save(article)
    return unless article.published?
    return unless article.section.type == 'Blog' # FIXME (relies on blog_url etc.)

    SERVICES.each do |service|
      # next if service[:section] && article.assigned_sections.select { |sec| sec if sec.section.name == service[:section].to_s }.length == 0
      # next if service[:tag] && article.tags(true).select { |tag| true if tag[:name] == service[:tag].to_s }.length == 0

      logger.info "sending #{service[:type]} ping to #{service[:url]}" # wtf, why can't this go into the thread?
      # Thread.new(service, article) do |service, article|
        #begin
          result = ping_service(service, article)
          logger.info "#{service[:type]} ping result => '#{result.inspect}'"
        #rescue Exception => e
        #  logger.error "unable to send #{service[:type]} ping to #{service[:url]} #{e.message}"
        #end
      # end
    end
  end

  protected
  
    def ping_service(service, article)
      case service[:type]
        when :rest
          rest_ping service[:url], article
        when :pom_get
          pom_get_ping service[:url], article, service[:extras]
        else
          xmlrpc_ping service[:url], article
      end
    end

    def pom_get_ping(url, article, extra = [])
      require_net_http_and_uri
      url = pom_get_url(url, article, extra)
      Net::HTTP.get(URI.parse(URI.escape(url)))
    end

    def rest_ping(url, article)
      # see the weblogs rest ping spec @ http://www.weblogs.com/api.html
      require_net_http_and_uri
      result = Net::HTTP.post_form URI.parse(url), rest_params(article)
      return result if result.kind_of?(Net::HTTPSuccess)
      raise Exception.new("result: #{result.inspect}")
    end

    def xmlrpc_ping(url, article)
      require 'xmlrpc/client'
      # see the weblogs xmlrpc ping spec @ http://www.weblogs.com/api.html
      XMLRPC::Client.new2(url).call2 'weblogUpdates.extendedPing', *xmlrpc_params(article)
    end

  private

    def pom_get_url(url, article, extra = [])
      "#{url}?title=#{blog_title(article)}&blogurl=#{blog_url(article)}&rssurl=#{blog_feed_url(article)}" + Array(extra) * '&'
    end

    def blog_title(article)
      article.section.title
    end

    def blog_url(article)
      controller.send :blog_url, article.section
    end

    def blog_feed_url(article)
      controller.send :blog_feed_url, article.section, :format => :atom
    end

    def rest_params(article)
      { "name" => blog_title(article), "url" => blog_url(article) }
    end

    def require_net_http_and_uri
      require 'net/http'
      require 'uri'
    end

    def xmlrpc_params(article)
      tags = article.tags.join('|') # spec want's tags pipe delimeted
      [blog_title(article), blog_url(article), blog_feed_url(article), tags]
    end

    def logger
      RAILS_DEFAULT_LOGGER
    end
end

require 'config'
