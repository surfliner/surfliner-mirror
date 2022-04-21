##
# Helper methods for SirTrevor block
# borrowed from upstream: https://github.com/projectblacklight/spotlight/blob/master/spec/support/features/test_features_helpers.rb

def fill_in_typeahead_field(opts = {})
  type = opts[:type] || "twitter"
  # Poltergeist / Capybara doesn't fire the events typeahead.js
  # is listening for, so we help it out a little:
  page.execute_script <<-EOF
        $("[data-#{type}-typeahead]:visible").val("#{opts[:with]}").trigger("input");
        $("[data-#{type}-typeahead]:visible").typeahead("open");
        $(".tt-suggestion").click();
  EOF

  find(".tt-suggestion", text: opts[:with], match: :first).click
end

def add_widget(type)
  click_add_widget

  # click the item + image widget
  expect(page).to have_css("button[data-type='#{type}']")
  find("button[data-type='#{type}']").click
end

def click_add_widget
  unless all(".st-block-replacer").present?
    expect(page).to have_css(".st-block-addition")
    first(".st-block-addition").click
  end
  expect(page).to have_css(".st-block-replacer")
  first(".st-block-replacer").click
end

def save_widget_block
  page.execute_script <<-EOF
    SirTrevor.getInstance().onFormSubmit();
  EOF
  click_button("Save changes")
  # verify that the page was created
  expect(page).not_to have_selector(".alert-danger")
  expect(page).to have_selector(".alert-info", text: "page was successfully updated")
end
