require "test_helper"

class PwaTest < ActionDispatch::IntegrationTest
  test "manifest is available without authentication" do
    get "/manifest"

    assert_response :success
    assert_includes response.body, "Happiness"
    assert_includes response.body, "#BC4090"
  end

  test "service worker is available without authentication" do
    get "/service-worker"

    assert_response :success
  end
end
