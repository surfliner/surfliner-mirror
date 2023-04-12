$(document).ready(function(){
  // open tab on click
  $('ul#items-tabs > li > a').click(function (e) {
    e.preventDefault();
    $(this).tab('show');

    // getting tab name
    var tabId = $(this).attr("href").substr(1);

    window.location.href = buildPagingUrl(window.location.href, tabId);
  });

  // store the current tab
  $("ul#items-tabs > li > a").on("shown.bs.tab", function (e) {
    var tabId = $(this).attr("href").substr(1);

    window.location.hash = tabId;
  });

  // open the initial tab
  var tabHash = window.location.hash || '#file_sets';
  $('ul#items-tabs > li > a[href="' + tabHash + '"]').tab('show');

  // change hash value for all tabs
  $('ul.pagination > li > a').each(function(i, a) {
    a.href = buildPagingUrl(a.href, tabHash.substr(1));
  });
});

function buildPagingUrl(url, tabId) {
  var urlObj = new URL(url);

  params = urlObj.searchParams;
  params.set('tab', tabId);
  urlObj.hash = tabId;

  return urlObj.toString();
}