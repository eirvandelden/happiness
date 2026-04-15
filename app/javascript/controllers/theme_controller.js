import { Controller } from "@hotwired/stimulus"

// This controller is optional - MVPA.css handles prefers-color-scheme automatically
// It's only needed if you want to support theme toggling without page reload
export default class extends Controller {
  static values = {
    colorScheme: { type: String, default: "system" },
    lightTheme: { type: String, default: "selenized_light" },
    darkTheme: { type: String, default: "selenized_dark" }
  }

  connect() {
    // Only apply if user has explicitly set a preference
    if (this.colorSchemeValue !== "system") {
      this.applyTheme()
    }
  }

  applyTheme() {
    if (this.colorSchemeValue === "light") {
      this.element.dataset.theme = this.lightThemeValue
    } else if (this.colorSchemeValue === "dark") {
      this.element.dataset.theme = this.darkThemeValue
    } else {
      // System - remove override, let MVPA.css handle it
      delete this.element.dataset.theme
    }
  }
}
