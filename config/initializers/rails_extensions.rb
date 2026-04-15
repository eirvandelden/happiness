# Auto-load Rails extensions from lib/rails_ext/
Rails.application.config.to_prepare do
  Dir.glob(Rails.root.join("lib/rails_ext/**/*.rb")).each do |file|
    require file
  end
end
