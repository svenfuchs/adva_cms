class AssetDeleteController < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    upload_summary = %(You have a uploaded a total of <strong>0 assets</strong>, using <strong>0 Bytes</strong>.)

    javascript = <<-END
$('#flash_notice').html("'rails.png' was deleted.").show();
$('#asset_1').remove();
$("#upload_summary").html("#{upload_summary}").effect("highlight", {}, 1000);
END

    response['Content-Type'] = "text/javascript"
    response.body = javascript
  end
end