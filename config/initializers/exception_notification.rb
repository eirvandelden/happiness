if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    campfire: { webhook_url: ENV.fetch("CAMPFIRE_WEBHOOK_URL") }
end
