class AssetDeleteController < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    javascript = <<-END
$('#flash_notice').html("'rails.png' was deleted.").show();
$('#asset_1').remove();
END

    response['Content-Type'] = "text/javascript"
    response.body = javascript
  end
end