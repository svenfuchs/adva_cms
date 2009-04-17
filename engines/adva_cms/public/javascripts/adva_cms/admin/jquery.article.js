$(document).ready(function() {
  $('#article_draft').click(function() {
    if($(this).attr('checked')) {
      $('#article_published_at_wrapper').hide();
    } else {
      $('#article_published_at_wrapper').show();
    }
  })
});
