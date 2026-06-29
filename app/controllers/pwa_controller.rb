class PwaController < ApplicationController
  allow_unauthenticated_access only: %i[manifest service_worker]
  skip_forgery_protection only: %i[manifest service_worker]

  # Renders the web app manifest.
  # @action GET
  # @route /manifest.json
  def manifest
    render template: "pwa/manifest", layout: false
  end

  # Renders the service worker.
  # @action GET
  # @route /service-worker.js
  def service_worker
    render template: "pwa/service-worker", layout: false
  end
end
