GoogleAnalyticsTracking = {};

// determine if a given link is an outbound link
GoogleAnalyticsTracking.isOutboundLink = function(link) {
  target = URI.parse(link);
  current = URI.parse(window.location);
  return (target.protocol == 'http' || target.protocol == 'https' || target.protocol == 'ftp') && target.host != current.host;
};

// track the outbound link with Google Analytics
if (typeof(pageTracker) == 'undefined') {
  pageTracker = null;
}

GoogleAnalyticsTracking.trackOutboundLink = function(link) {
  if(pageTracker && GoogleAnalyticsTracking.isOutboundLink(link.href)) {
    hostName = URI.parse(link).host.replace(/www\./, '');;
    pageTracker._trackEvent('Outbound links [' + hostName + ']', 'Click', link.href);
  }
};

// find all outbound links and mark them accordingly
GoogleAnalyticsTracking.markOutboundLinks = function() {
  $('a').each(function() {
    if(GoogleAnalyticsTracking.isOutboundLink(this.href)) {
      this.addClass('outbound');
      this.attr('onclick', "GoogleAnalyticsTracking.trackOutboundLink(this); return false;");
    }
  });
};

$(document).ready(function() {
  // mark outbound links and apply hook
  if(pageTracker) {
    GoogleAnalyticsTracking.markOutboundLinks();
  }
});