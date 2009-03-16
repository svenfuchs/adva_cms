var CommentForm = {
  init: function() {
    var user_name = unescape(Cookie.get('uname')).replace(/\+/g, " ");
    if (user_name) {
		try { $$('#registered_author span')[0].update(user_name); } catch(err) {}
		try { $('registered_author').show(); } catch(err) {}
		try { $('anonymous_author').hide(); } catch(err) {}
    }
  }
}

var LoginLinks = {
	init: function() {
		var user_id = Cookie.get('uid');
		var user_name = unescape(Cookie.get('uname')).replace(/\+/g, " ");
		try { 
			this.update_user_links(user_name) 
		} catch(err) {}
		if (user_id) {
			try { 
				$('logout_links').show(); 
				$('login_links').hide();
			} catch(err) {}
		}
	},

	update_user_links: function(user_name) {
		if($('logout_link'))   $('logout_link').href = $('logout_link').href + "?return_to=" + escape(document.location.href);
		if($('login_link'))    $('login_link').href  = $('login_link').href  + "?return_to=" + escape(document.location.href);
		
		$$('span.user_name').invoke('update', user_name);
	}
}

/* Date functions */

Date.UTCNow = function() {
  d = new Date();
  utc = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds()));
  // we need to correct the timezone offset because JS sucks really bad with timezones ...
  return new Date(utc.getTime() + utc.getTimezoneOffset()*60000);
}

// parse an ISO8601 UTC date string (YYYY-mm-ddZHH:MM:SSZ)
Date.parseISO8601 = function(iso8601_date) {
  return new Date(Date.parse(iso8601_date.replace(/-/g, '/').replace('T', ' ').substr(0, 19))); // always has exactly 19 chars
}

distanceOfTimeInWords = function(seconds) {
  d = seconds/60; // in minutes

  if (d < 1) return 'less than a minute';

  d = Math.ceil(d); // if it's more than a minute, ceil it
  if (d < 50) return (d + ' minute' + (d == 1 ? '' : 's'));
  if (d < 90) return 'about one hour';
  if (d < 1080) return (Math.round(d/60) + ' hours');
  if (d < 1440) return 'one day';
  if (d < 2880) return 'about one day';
  else return (Math.round(d/1440) + ' days');
}

timeAgoInWords = function(iso8601_date) {
  utc_date = Date.parseISO8601(iso8601_date);
  utc_now  = Date.UTCNow();
  d = (utc_now.getTime() - utc_date.getTime())/1000; // in seconds
	if (d > 0) {
  	return distanceOfTimeInWords(d) + ' ago';
	} else {
  	return 'in '+ distanceOfTimeInWords(-d);
	}
}

createAndFormatDateSpan = function(abbr) {
  // create a new span element and set its title to the abbr's innerHTML and its value to the timeAgoInWords string
  abbr.update(new Element('span', { title: abbr.innerHTML }).update(timeAgoInWords(abbr.title))); // only used for past dates right now so we can safely use time_ago_in_words here
}

/* Link functions */

// determine if a given link is an outbound link
URI.parseOptions.strictMode = true;

GoogleAnalyticsTracking = {};

GoogleAnalyticsTracking.isOutboundLink = function(link) {
  targetURI = URI.parse(link);
  currentURI = URI.parse(window.location);
  /*
  targetHost = link.split('/')[2].replace(/www\./, ''); // [0] is the protocol, [1] is empty
  currentHost = window.location.host.replace(/www\./, '');
  */
  return ['http', 'https', 'ftp'].include(targetURI.protocol) && targetURI.host != currentURI.host;
}

// track the outbound link with Google Analytics
if (typeof(pageTracker) == 'undefined') {
  pageTracker = null;
}
GoogleAnalyticsTracking.trackOutboundLink = function(link) {
  if(pageTracker && GoogleAnalyticsTracking.isOutboundLink(link.href)) {
    hostName = URI.parse(link).host.replace(/www\./, '');;
    //hostName = link.href.split('/')[2].replace(/www\./, '');
    pageTracker._trackEvent('Outbound links [' + hostName + ']', 'Click', link.href);
    //window.location.href = link.href;
  }
}

// find all outbound links and mark them accordingly
GoogleAnalyticsTracking.markOutboundLinks = function() {
  $$('a').each(function(link) {
    if(GoogleAnalyticsTracking.isOutboundLink(link.href)) {
      link.addClassName('outbound');
      link.writeAttribute('onclick', "GoogleAnalyticsTracking.trackOutboundLink(this); return false;");
    }
  });
}

/* event handlers */
Event.onReady(function() {
  if($('anonymous_author')) {
	  CommentForm.init();
  }
	if($('logout_links')) {
		LoginLinks.init();
	}
  // parse all microformatted dates and re-format them as time distance
  $$('abbr.datetime').each(function(abbr) {
    createAndFormatDateSpan(abbr);
  });
  // mark outbound links and apply hook
  if(pageTracker) {
    GoogleAnalyticsTracking.markOutboundLinks();
  }
});
