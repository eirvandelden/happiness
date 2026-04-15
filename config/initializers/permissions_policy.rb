# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.permissions_policy do |policy|
    # Restrict potentially sensitive permissions
    policy.accelerometer :none
    policy.ambient_light_sensor :none
    policy.autoplay :none
    policy.camera :none
    policy.geolocation :none
    policy.gyroscope :none
    policy.magnetometer :none
    policy.microphone :none
    policy.payment :none
    policy.usb :none

    # Allow fullscreen for own origin
    policy.fullscreen :self
  end
end
