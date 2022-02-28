# frozen_string_literal: true

def sign_in(user = nil)
  visit destroy_user_session_path
  user ||= FactoryBot.create(:user)
  visit new_user_session_path
  fill_in "Email", with: user.email
  fill_in "Password", with: user.password
  click_button "Log in"
  expect(page).not_to have_text "Invalid email or password."
end
