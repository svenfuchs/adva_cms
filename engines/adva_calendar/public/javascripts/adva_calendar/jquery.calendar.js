$(document).ready(function() {
  if($('.calendar_cell').length > 0) {
    $.ajax({
      url: $('.calendar a')[0].href.replace(/([\d\/]*)?\.html/, '.js'),
      type: 'get',
			dataType: 'script'
    });
  }

	$('.calendar a.nav').live('click', function(event) {
		event.preventDefault();
		$.ajax({
      url: this.href.replace(/([\d\/]*)?\.html/, '$1.js'),
      type: 'get',
			dataType: 'script'
    });
	});
});