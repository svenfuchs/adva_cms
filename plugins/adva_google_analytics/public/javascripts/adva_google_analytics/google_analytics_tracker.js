// track the outbound link with Google Analytics
GoogleAnalyticsTracker = $.klass({
  onclick: function() {
    var uri = this.element.attr("href");
    this.track(uri);
  },

  track: function(uri) {
    if (this.isOutbound(uri)) {
      host = URI.parse(uri).host.replace(/^www\./, "");
      pageTracker._trackEvent('Outbound links [' + host + ']', 'Click', uri);
    }
  },

  isOutbound: function(uri) {
    if(URI.parse(uri).host != URI.parse(window.location).host) {
      return true;
    } else {
      return false;
    }
  }
});

jQuery(function($) {
  if (typeof(pageTracker) != 'undefined') {
    $("a[href^=http]").attach(GoogleAnalyticsTracker);
  }
});
