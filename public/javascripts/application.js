var CommentForm = {
  show: function(name) {
    var username = Cookie.get('uname');
    if (username) {
      $$('#' + name + '_user span')[0].update(username);
      $(name + '_user').show();
      $(name + '_anonymous').hide();
    }
  }        
}

Event.onReady(function() {
  if($('post_form')) {
	  CommentForm.show('post');
  }
  if($('comment_form')) {
	  CommentForm.show('comment');
  }
});  