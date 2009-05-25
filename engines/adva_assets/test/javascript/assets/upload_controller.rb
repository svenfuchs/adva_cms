class UploadController < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    response['Content-Type'] = 'text/html; charset=UTF-8'
    response.body = "" # cannot simulate respond_to_parent behavior, because it performs a redirect.
  end
end