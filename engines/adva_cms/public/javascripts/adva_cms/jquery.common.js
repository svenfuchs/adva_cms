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
  $('#toggle_draft').click(Form.toggleDraft)
});
