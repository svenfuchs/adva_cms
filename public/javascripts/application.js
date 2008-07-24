var CommentForm = {
  init: function() {
    var username = Cookie.get('uname');
    if (username) {
			try { $$('#registered_author span')[0].update(username); } catch(err) {}
			try { $('registered_author').show(); } catch(err) {}
			try { $('anonymous_author').hide(); } catch(err) {}
    }
  }        
}

Event.onReady(function() {
  if($('anonymous_author')) {
	  CommentForm.init();
  }
});  