require "test_helper"

class AndroidNavigationRulesTest < ActionDispatch::IntegrationTest
  test "the Android app fetches its navigation rules without signing in" do
    get "/configurations/android_v1.json"

    assert_response :success
  end

  test "the rules are served whether or not the address ends in .json" do
    get "/configurations/android_v1"

    assert_response :success
    assert_equal "application/json", response.media_type
  end

  test "every path opens as a web screen that can be pulled to refresh" do
    get "/configurations/android_v1.json"

    every_path = navigation_rules["rules"].sole

    assert_equal [ ".*" ], every_path["patterns"]
    assert_equal "hotwire://fragment/web", every_path.dig("properties", "uri")
    assert_equal "default", every_path.dig("properties", "context")
    assert_equal true, every_path.dig("properties", "pull_to_refresh_enabled")
  end

  private
    def navigation_rules
      JSON.parse(response.body)
    end
end
