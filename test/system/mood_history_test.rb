require "application_system_test_case"

class MoodHistoryTest < ApplicationSystemTestCase
  test "user logs a mood and sees it in their history" do
    system_sign_in_as(users(:user))

    visit new_state_of_mind_path
    check "emotion_happy"
    fill_in "state_of_mind_note", with: "Walked along the canal"
    click_button I18n.t("state_of_minds.new.submit")

    assert_current_path state_of_minds_path
    assert_text "Walked along the canal"
  end
end
