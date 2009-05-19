class DetachController < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    javascript = <<-END
$('#flash_notice').html("flower.jpg unassigned from this article.").show();
$('#attached_asset_4').remove();
AssetWidget.updateSelected();
END
    response['Content-Type'] = "text/javascript"
    response.body = javascript
  end
end