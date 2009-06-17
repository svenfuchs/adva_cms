class BucketAddController < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    javascript = <<-END
$('#flash_notice').html('rails.png assigned to this bucket.').show();
$('#bucket_assets').append('<li><a href="/assets/rails.png" target="_blank"><img="/assets/rails.png" /></a></li>');
END

    response['Content-Type'] = "text/javascript"
    response.body = javascript
  end
end