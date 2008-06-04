var CommentForm = {
  show: function() {
    var username = Cookie.get('username');
    if (username) {
      $$('#comment_user span')[0].update(username);
      $('comment_user').show();
      $('comment_anonymous').hide();
    }
  }        
}

Event.onReady(function() {
  if($('comment_form')) {
	  CommentForm.show();
 }
});  