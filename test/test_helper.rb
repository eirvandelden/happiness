ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "capybara/rails"

module ActiveSupport
  class TestCase
    # Add test helper methods from test/helpers/
    Dir[Rails.root.join("test/helpers/*.rb")].each { |f| require f }

    # Include helper modules
    include SessionTestHelper

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors, with: :threads)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
