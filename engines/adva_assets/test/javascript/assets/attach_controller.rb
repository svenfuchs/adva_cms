class AttachController < WEBrick::HTTPServlet::AbstractServlet
  def do_POST(request, response)
    partial = <<-END
<li id="attached_asset_23" class="asset attached_asset  selected">
  <a href="/assets/pony.jpg"><img alt="pony.jpg" src="/assets/pony.tiny.jpg?1240920626" /></a>
  <div style="display:none">
    <a href="#"><img alt="Add" class="attach_asset" height="16" id="attach_attached_asset_23" src="/images/adva_cms/icons/add.png?1239718032" width="16" /></a>
    <a href="#"><img alt="Delete" class="detach_asset" height="16" id="detach_attached_asset_23" src="/images/adva_cms/icons/delete.png?1239718032" width="16" /></a>
  </div>  
</li>
END
    javascript = <<-END
$('#flash_notice').html("pony.jpg assigned to this article.").show();
$('#attached_assets').html('');
$('#attached_assets').append('#{partial.gsub("\n", "")}');
AssetWidget.updateSelected();    
END
    response['Content-Type'] = "text/javascript"
    response.body = javascript
  end
end