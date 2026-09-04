require "test_helper"

class AndroidNavigationRulesTest < ActionDispatch::IntegrationTest
  test "the Android app fetches its navigation rules without signing in" do
    get "/configurations/android_v1.json"

    assert_response :success
    assert_equal [ "hotwire://fragment/web" ], navigation_rules["rules"].map { |rule| rule.dig("properties", "uri") }
  end

  test "every page is presented as a normal screen" do
    get "/configurations/android_v1.json"

    every_path = navigation_rules["rules"].sole["patterns"]
    assert_equal [ ".*" ], every_path
  end

  private
    def navigation_rules
      JSON.parse(response.body)
    end
end
