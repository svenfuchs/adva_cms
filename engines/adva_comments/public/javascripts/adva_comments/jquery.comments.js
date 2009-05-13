var CommentForm = {
  init: function() {
		var user_name = Cookie.get('uname');
    if (user_name) {
    	user_name = unescape(user_name).replace(/\+/g, " ");
			try { $('#registered_author span').each(function() { $(this).html(user_name); }); } catch(err) {}
			try { $('#registered_author').show(); } catch(err) {}
			try { $('#anonymous_author').hide();  } catch(err) {}
    }
  }
};

var Comment = {
  preview: function(event) {
    event.preventDefault();
    $.ajax({
      url: this.href,
      type: 'post',
      dataType: 'html',
      data: $('form#comment_form').serializeArray(),
      success: function(data, status) {
        $('#preview').html(data);
      },
      beforeSend: function(xhr) {
        $('#comment_preview_spinner').show();
      },
      complete: function(xhr, status) {
        $('#comment_preview_spinner').hide();
      }
    });
  }
}

$(document).ready(function() {
  if($('#anonymous_author')) {
	  CommentForm.init();
  }

  $('a#preview_comment').show();
  $('a#preview_comment').click(Comment.preview);
});
