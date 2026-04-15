Faultline.configure do |config|
  # Restrict the /faultline dashboard to admin users only.
  # Uses the template's existing session cookie + admin role check,
  # matching the pattern in app/controllers/concerns/authentication.rb.
  config.authenticate_with = lambda { |request|
    session_token = request.cookie_jar.signed[:session_token]
    session = session_token && Session.find_by(token: session_token)
    session&.user&.admin?
  }
end
