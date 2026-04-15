# Be sure to restart your server when you modify this file.

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src :self, :https, :data
    policy.img_src :self, :https, :data, :blob
    policy.object_src :none
    policy.script_src :self, :https
    policy.style_src :self, :https, :unsafe_inline
    # If you need to enable unsafe_inline for scripts, do so thoughtfully
    # policy.script_src :self, :https, :unsafe_inline
  end

  # Generate secure random nonces for inline scripts
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }

  # Report CSP violations (useful for debugging)
  # Uncomment to enable CSP violation reports
  # config.content_security_policy_report_only = true
end
