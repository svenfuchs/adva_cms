class BucketClearController < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    javascript = <<-END
$('#flash_notice').html('Asset bucket has been cleared.').show();
$('#bucket_assets').html('');
END

    response['Content-Type'] = "text/javascript"
    response.body = javascript
  end
end