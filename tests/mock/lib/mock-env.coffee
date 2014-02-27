jsdom     = require('jsdom').jsdom

`
root = root || {};
window = jsdom().createWindow();
window.jQuery = window.$ = jQuery = $ = require("jquery").create(window);
location = window.location;
document = window.document;
console = window.console;
navigator = window.navigator;
`
window.history =
  pushState : (obj, title, url) ->
    window.location.href = url
    $(window).trigger 'popstate'
