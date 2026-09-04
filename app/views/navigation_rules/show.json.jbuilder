# Sent even though it is empty: the app reads this key, and a missing one would
# leave it to the app's JSON parser to invent a default.
json.settings({})

json.rules do
  json.child! do
    json.patterns [ ".*" ]

    json.properties do
      json.context "default"
      json.uri "hotwire://fragment/web"
      json.pull_to_refresh_enabled true
    end
  end
end
