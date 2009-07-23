var Form = {
  toggleDraft: function() {
    if($(this).attr('checked')) {
      $('#publish_date_wrapper').hide();
    } else {
      $('#publish_date_wrapper').show();
    }
  }
}

$(document).ready(function() {
  $('#toggle_draft').click(Form.toggleDraft);
  
  if($(".hint").size() > 0) {
    $(".hint").each(function() {
      if(!$(this).hasClass('text_only')) {
        var label = $("label[for=" + this.getAttribute('for') + "]");
      	 
        if(label) {
          $(this).appendTo(label);
          $(this).addClass("move_up");
        }
		
        $(this).addClass("enabled");
      }
    })

    $('.hint.enabled').tooltip({
      id: 'helptip',
      delay: 0,
      track: true,
      bodyHandler: function() {
        return $(this).html();
      }
    });
  }
});
