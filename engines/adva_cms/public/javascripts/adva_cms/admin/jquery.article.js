$(document).ready(function() {
  $('a#add_excerpt').click(function(event) {
    event.preventDefault();
    $('#article_excerpt_wrapper').show();
    $('#add_excerpt_hint').hide();
    $('#hide_excerpt_hint').show();
    $('#article_excerpt').removeAttr('disabled');
  });

  $('a#hide_excerpt').click(function(event) {
    event.preventDefault();
    $('#article_excerpt_wrapper').hide();
    $('#hide_excerpt_hint').hide();
    $('#add_excerpt_hint').show();
    $('#article_excerpt').attr('disabled', 'disabled');
  });
});
