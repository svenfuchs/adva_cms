// From http://wiki.script.aculo.us/scriptaculous/show/Cookie
var Cookie = {
  set: function(name, value, daysToExpire) {
    var expire = '';
    if(!daysToExpire) daysToExpire = 365;
    var d = new Date();
    d.setTime(d.getTime() + (86400000 * parseFloat(daysToExpire)));
    expire = 'expires=' + d.toGMTString();
    var path = "path=/"
    var cookieValue = escape(name) + '=' + escape(value || '') + '; ' + path + '; ' + expire + ';';
    return document.cookie = cookieValue;
  },
  get: function(name) {
    var cookie = document.cookie.match(new RegExp('(^|;)\\s*' + escape(name) + '=([^;\\s]+)'));
    return (cookie ? unescape(cookie[2]) : null);
  },
  erase: function(name) {
    var cookie = Cookie.get(name) || true;
    Cookie.set(name, '', -1);
    return cookie;
  },
  eraseAll: function() {
    // Get cookie string and separate into individual cookie phrases:
    var cookieString = "" + document.cookie;
    var cookieArray = cookieString.split("; ");

    // Try to delete each cookie:
    for(var i = 0; i < cookieArray.length; ++ i)
    {
      var singleCookie = cookieArray[i].split("=");
      if(singleCookie.length != 2)
        continue;
      var name = unescape(singleCookie[0]);
      Cookie.erase(name);
    }
  },
  accept: function() {
    if (typeof navigator.cookieEnabled == 'boolean') {
      return navigator.cookieEnabled;
    }
    Cookie.set('_test', '1');
    return (Cookie.erase('_test') === '1');
  },
  exists: function(cookieName) {
    var cookieValue = Cookie.get(cookieName);
    if(!cookieValue) return false;
    return cookieValue.toString() != "";
  }
};
