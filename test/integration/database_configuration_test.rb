require "test_helper"

class DatabaseConfigurationTest < ActiveSupport::TestCase
  test "defaults max connections to five" do
    previous_max_threads = ENV.delete("RAILS_MAX_THREADS")

    configuration = ActiveRecord::DatabaseConfigurations.new(
      Rails.application.config.database_configuration
    )

    primary_config = configuration.configs_for(env_name: "test", name: "primary")

    assert_equal 5, primary_config.configuration_hash[:max_connections]
  ensure
    ENV["RAILS_MAX_THREADS"] = previous_max_threads if previous_max_threads
  end
end
