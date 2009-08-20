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
	$('.hint.enabled').each(function() {
	  $(this).qtip({
		content: $(this).html(),
		position: { corner: { target:  'topMiddle', tooltip: 'bottomMiddle' }, adjust: { screen: true, scroll: true } },
	    // FIXME tip option for qtip is broken currently on firefox, add this when this is fixed: tip: 'bottomMiddle'
	    style: { background: '#FBF7E4', color: '#black', name: 'cream', 
	             border: { width: 3, radius: 5, color: '#DDDDDD' } },
		show: { delay: 0, when: { event: 'click' } },
		hide: { when: { event: 'unfocus' }, effect: { length: 1000 } }
	  });
	});
  }
});
