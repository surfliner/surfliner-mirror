$(document).ready(function(){
  if ($('.dataTables_wrapper').length === 0) {
    // Create datatable for workflows.
    // This will override hyrax workflows for batch workflow moving support.
    $('.datatableworkflows').DataTable();

    var workflow_tabs = ["under-review", "published"]
    workflow_tabs.forEach(function (tab, index) {
      // Hide default search filter to use the custom search box
      $(`#${tab}`).find(".dataTables_filter").hide();

      workflow_widge = $(`#workflow-actions-${tab}`);
      if (workflow_widge.html() != null && workflow_widge.html().trim().length == 0) {
        $(`#${tab}`).find(".btn-batch-workflow").attr("disabled", true);
      }
    });
  }

});

// Overlay for batch workflow form
function batch_review() {
  active_tab = $("#under-review").is(":visible") ? "under-review" : "published";
  workflow_widge = $("#workflow-actions-" + active_tab)
  workflow_widge.show();
}

// Hide batch workflow form overlay
function cancel_workflow_action() {
  active_tab = $("#under-review").is(":visible") ? "under-review" : "published";
  $("#workflow-actions-" + active_tab).hide();
}