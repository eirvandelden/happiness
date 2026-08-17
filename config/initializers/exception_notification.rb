if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    campfire: {
      webhook_url: ENV.fetch("CAMPFIRE_WEBHOOK_URL", nil),
      app_name: ENV.fetch("APP_NAME", Rails.application.class.module_parent_name)
    }
end
