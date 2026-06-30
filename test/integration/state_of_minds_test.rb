require "test_helper"

class StateOfMindsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:user)
    sign_in_as(@user)
    follow_redirect!
  end

  test "user can visit new state of mind form" do
    get new_state_of_mind_path
    assert_response :success
    assert_select "form"
    assert_select "input[type=range]"   # mood score slider
    assert_select "input[type=checkbox]" # emotion/context checkboxes
  end

  test "user can submit a valid state of mind entry" do
    assert_difference "StateOfMind.count" do
      post state_of_minds_path, params: {
        state_of_mind: {
          mood_score: 4,
          emotions: [ "happy", "calm" ],
          contexts: [ "work" ]
        }
      }
    end
    assert_redirected_to state_of_minds_path
  end

  test "invalid submission shows errors" do
    post state_of_minds_path, params: { state_of_mind: { note: "Missing mood" } }

    assert_response :unprocessable_entity
    assert_select "aside[role=alert]"
  end

  test "invalid submission preserves selected emotions and contexts" do
    post state_of_minds_path, params: {
      state_of_mind: {
        emotions: [ "happy" ],
        contexts: [ "work" ]
      }
    }

    assert_response :unprocessable_entity
    assert_select "input#emotion_happy[checked]"
    assert_select "input#context_work[checked]"
  end

  test "invalid entry type shows errors" do
    post state_of_minds_path, params: { state_of_mind: { mood_score: 4, entry_type: "unknown" } }

    assert_response :unprocessable_entity
    assert_select "aside[role=alert]"
  end

  test "user can submit an entry with a note" do
    post state_of_minds_path, params: {
      state_of_mind: {
        mood_score: 3,
        emotions: [ "calm" ],
        contexts: [ "health" ],
        note: "Just a test note"
      }
    }
    assert_redirected_to state_of_minds_path
    assert_equal "Just a test note", StateOfMind.last.note
  end

  test "index shows empty state when no entries" do
    StateOfMind.destroy_all
    get state_of_minds_path
    assert_response :success
    assert_match I18n.t("state_of_minds.index.empty"), response.body
    assert_select "a[href='#{new_state_of_mind_path}']"
  end

  test "index shows entry after submission" do
    get state_of_minds_path
    assert_response :success
    # fixture entry_one for this user exists
    assert_match "Good day", response.body
  end

  test "index shows mood trend SVG chart when entries exist" do
    get state_of_minds_path
    assert_response :success
    assert_select "svg", minimum: 1
  end

  test "index shows emotion frequency SVG chart when entries exist" do
    get state_of_minds_path
    assert_response :success
    assert_select "svg", minimum: 2
  end
end
