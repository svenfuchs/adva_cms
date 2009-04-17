var Excerpt = {
  show: function(event) {
    event.preventDefault();
    $('#article_excerpt_wrapper').show();
    $('#add_excerpt_hint').hide();
    $('#hide_excerpt_hint').show();
    $('#article_excerpt').removeAttr('disabled');
  },

  hide: function(event) {
    event.preventDefault();
    $('#article_excerpt_wrapper').hide();
    $('#hide_excerpt_hint').hide();
    $('#add_excerpt_hint').show();
    $('#article_excerpt').attr('disabled', 'disabled');
  }
}

$(document).ready(function() {
  $('a#add_excerpt').click(Excerpt.show);
  $('a#hide_excerpt').click(Excerpt.hide);
});
