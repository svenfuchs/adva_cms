$(document).ready(function() {
  $('#calendar_event_draft').click(function() {
    if($(this).attr('checked')) {
      $('#publish_date').hide();
    } else {
      $('#publish_date').show();
    }
  })
});
