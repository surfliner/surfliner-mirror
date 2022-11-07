# For use with javascript collection selector that allows for searching for an existing collection from add to collection modal.
# Does not save the selection.  The calling test is expected to click Save and validate the collection membership was added to the work.
# @param [Collection] collection to select
def select_member_of_collection(collection)
  find("#s2id_member_of_collection_ids").click
  find(".select2-input").set(collection.title.first)
  wait_for_select2
  all("li.select2-result span").first.click
end

# For use with javascript path selector that allows for searching for directories on S3/Minio.
# @param [path] the path to select
def select_s3_path(s3_path)
  find("#s2id_files_location").click
  find(".select2-input").set(s3_path)

  wait_for_select2

  within ".select2-result" do
    find("span", text: s3_path).click
  end
end

def select_child_work(component_title)
  find("#s2id_generic_object_find_child_work").click
  find(".select2-input").set(component_title)
  wait_for_select2
  all("li.select2-result span.select2-match").first.click
end

def wait_for_select2
  # Crude way of waiting for the AJAX response
  select2_results = false
  begin_time = current_time = Time.now.to_f
  until select2_results
    raise("Waited 20 seconds for AJAX select2 selector, but never found it.") if
      (current_time - begin_time) > 20
    select2_results = page.has_css?("li.select2-result")
    current_time = Time.now.to_f
  end
end
