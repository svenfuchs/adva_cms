class SearchController < WEBrick::HTTPServlet::AbstractServlet
  def do_GET(request, response)
    javascript = <<-JS
$("#search_assets_result").append('<li><a href="/adva_assets/assets/rails.png"><img alt="rails logo" src="/adva_assets/assets/rails.thumb.png" style="thumb"></a></li>');
JS

    response['Content-Type'] = 'text/javascript; charset=utf-8'
    response.body = javascript
  end
end