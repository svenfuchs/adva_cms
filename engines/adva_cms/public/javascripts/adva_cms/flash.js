var Flash = {
	transferFromCookies: function() {
	  var data = JSON.parse(unescape(Cookie.get("flash")).gsub(/\+/, ' '));
	  if(!data) data = {};
	  Flash.data = data;
	  Cookie.erase("flash");
	},
  // When given an flash message, wrap it in a list and show it on the screen.  
  // This message will auto-hide after a specified amount of milliseconds
  show: function(flashType, message) {
    // new Effect.ScrollTo('flash_' + flashType);
    $('flash_' + flashType).innerHTML = '';
    if(message.toString().match(/<li/)) message = "<ul>" + message + '</ul>'
    $('flash_' + flashType).innerHTML = message;

		if(Flash.applyEffects) {
    	new Effect.Appear('flash_' + flashType, {duration: 0});
    	setTimeout(Flash['fade' + flashType[0].toUpperCase() + flashType.slice(1, flashType.length)].bind(this), 5000)
		} else {
			var flash = $('flash_' + flashType)
			flash.show();
	    Event.observe(flash, 'click', function() { new Effect.Fade(this, { duration: 0.5 }); });
		}
  },
  errors: function(message) {
    this.show('error', message);
  },
  notice: function(message) {
    this.show('notice', message);
  },  
  // Responsible for fading notices level messages in the dom    
  fadeNotice: function() {
    new Effect.Fade('flash_notice', {duration: 1});
    // new Effect.BlindUp('flash_notice', {duration: 1});
  },  
  // Responsible for fading error messages in the DOM
  fadeError: function() {
    new Effect.Fade('flash_error', {duration: 1});
  }
}
Flash.data = {};
Flash.applyEffects = false;

Event.onReady(function() {
	Flash.transferFromCookies();
  ['notice', 'error'].each(function(type) {		
    if(Flash.data[type]) Flash.show(type, Flash.data[type].toString().gsub(/\+/, ' '));
  })
});
