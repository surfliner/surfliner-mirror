$(document).ready(function(){
  // store the current tab
  $("ul#items-tabs > li > a").on("shown.bs.tab", function (e) {
    var tabId = $(this).attr("href").substr(1);

    window.location.hash = tabId;
  });

  // open the initial tab
  var tabHash = window.location.hash || '#file_sets';
  $('ul#items-tabs > li > a[href="' + tabHash + '"]').tab('show');

  // load full page when page link is clicked instead.
  tabId = tabHash.substr(1);
  $(`${tabHash} ul.pagination > li > a`).each(function(i, a) {
    var url = buildPagingUrl(a.href, tabId);

    $(a).removeAttr('href');
    $(a).css('cursor', 'pointer');
    $(a).click(function (e) {
      e.preventDefault();
      window.location.href = url;
    });
  });
});

// load the page for the tab
function load_tab_content(tab) {
  $(`#${tab}`).tab('show');

  window.location.href = buildPagingUrl(window.location.href, tab);
}
  
// rebuild the url to include the tab id to load file sets or component data
function buildPagingUrl(url, tabId) {
  var urlObj = new URL(url);

  params = urlObj.searchParams;
  params.set('tab', tabId);
  urlObj.hash = tabId;

  return urlObj.toString();
}