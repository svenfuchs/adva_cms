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
  
  $("p.hint").addClass("enabled");
  $('p.hint.enabled').tooltip({
	id: 'helptip',
    delay: 0,
	track: true,
	bodyHandler: function() {
	  return $(this).html();
	}
  });
});
