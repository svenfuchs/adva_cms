$(document).ready(function() {
  if($('.calendar_cell').length > 0) {
    $.ajax({
      url: $('.calendar a')[0].href.replace(/([\d\/]*)?\.html/, '.js'),
      type: 'get'
    });
  }
});