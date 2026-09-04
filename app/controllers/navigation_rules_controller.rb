class NavigationRulesController < ApplicationController
  allow_unauthenticated_access

  NAVIGATION_RULES = {
    settings: {},
    rules: [
      {
        patterns: [ ".*" ],
        properties: {
          context: "default",
          uri: "hotwire://fragment/web",
          pull_to_refresh_enabled: true
        }
      }
    ]
  }.freeze

  def show
    render json: NAVIGATION_RULES
  end
end
