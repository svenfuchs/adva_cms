var LoginLinks = {
	init: function() {
		var user_id = Cookie.get('uid');
		var user_name = decodeURIComponent(Cookie.get('uname')).replace(/\+/g, " ");
		try {
			LoginLinks.update_user_links(user_name)
		} catch(err) {}
		if (user_id) {
			try {
				$('#logout_links').show();
				$('#login_links').hide();
			} catch(err) {}
		}
	},

	update_user_links: function(user_name) {
		if($('#logout_link')) $('#logout_link').href = $('#logout_link').href + "?return_to=" + escape(document.location.href);
		if($('#login_link'))  $('#login_link').href  = $('#login_link').href  + "?return_to=" + escape(document.location.href);

		$('span.user_name').each(function() {
		  $(this).html(user_name);
		});
	}
};

$(document).ready(function() {
	if($('#logout_links')) {
		LoginLinks.init();
	}
	jQuery('#lang').bind('change',function(){
	  url = location.href;
	  if(url.match(/\/[\w]{2}\/admin/)) {
      location.href = url.replace(/\/[\w]{2}\/admin/, '/' + jQuery(this).val() + '/admin');
	  } else {
	    location.href = url.replace(/\/admin/, '/' + jQuery(this).val() + '/admin');
	  }
	});
});
