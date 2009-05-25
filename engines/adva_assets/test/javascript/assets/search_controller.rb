class SearchController < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    response['Content-Type'] = 'text/html; charset=UTF-8'
    response.body = "adva logo"
  end
end