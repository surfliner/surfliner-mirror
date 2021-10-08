# For use with javascript collection selector that allows for searching for an existing collection from add to collection modal.
# Does not save the selection.  The calling test is expected to click Save and validate the collection membership was added to the work.
# @param [Collection] collection to select
def select_member_of_collection(collection) # rubocop:disable Metrics/MethodLength
  find("#s2id_member_of_collection_ids").click
  find(".select2-input").set(collection.title.first)

  # Crude way of waiting for the AJAX response
  select2_results = false
  begin_time = current_time = Time.now.to_f
  while !select2_results && (current_time - begin_time) < 3
    select2_results = page.has_css?("li.select2-result")
    current_time = Time.now.to_f
  end

  all("li.select2-result span").first.click
end
