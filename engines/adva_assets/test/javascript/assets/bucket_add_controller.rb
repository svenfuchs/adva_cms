class BucketAddController < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    javascript = <<-END
$('#flash_notice').html('rails.png assigned to this bucket.').show();
$('#bucket_assets').append('<li><a href="/adva_assets/assets/rails.png" target="_blank"><img="/adva_assets/assets/rails.thumb.png" /></a></li>');
END

    response['Content-Type'] = "text/javascript"
    response.body = javascript
  end
end