Appkit.configure do |config|
  config.app_name          = -> { Rails.application.class.module_parent_name }
  config.brand_color       = "#BC4090"
  config.timezone_attribute = :timezone

  # Happiness's role enum uses :admin (not the engine default :administrator).
  config.first_run = ->(user_params) { User.create!(user_params.merge(role: :admin)) }
end
