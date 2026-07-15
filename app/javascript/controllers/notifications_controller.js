import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]
  static values = {
    unsupported: String,
    blocked: String,
    enabled: String,
    failed: String,
  }

  async connect() {
    const registration = await this.reminderRegistration();
    if (!registration) return this.showStatus(this.unsupportedValue);

    if (Notification.permission === 'granted') {
      await this.finishEnabling(registration);
    } else if (Notification.permission === 'denied') {
      this.showStatus(this.blockedValue);
    } else {
      this.showButton();
    }
  }

  async enable() {
    const registration = await this.reminderRegistration();
    if (!registration) return this.showStatus(this.unsupportedValue);

    const permission = await Notification.requestPermission();
    if (permission !== 'granted') return this.showStatus(this.blockedValue);

    await this.finishEnabling(registration);
  }

  async finishEnabling(registration) {
    if (await this.registerSync(registration)) {
      this.showStatus(this.enabledValue);
    } else {
      this.showStatus(this.failedValue, { keepButton: true });
    }
  }

  async registerSync(registration) {
    try {
      await registration.periodicSync.register('happiness-reminder', {
        minInterval: 4 * 60 * 60 * 1000,
      });
    } catch {
      return false;
    }

    return true;
  }

  async reminderRegistration() {
    if (!this.hasRequiredApis()) return null;

    const registration = await navigator.serviceWorker.ready;
    if (!('periodicSync' in registration)) return null;

    return registration;
  }

  hasRequiredApis() {
    return 'serviceWorker' in navigator && 'Notification' in window;
  }

  showStatus(message, { keepButton = false } = {}) {
    this.statusTarget.textContent = message;
    this.statusTarget.hidden = false;
    this.buttonTarget.hidden = !keepButton;
  }

  showButton() {
    this.buttonTarget.hidden = false;
    this.statusTarget.hidden = true;
    this.statusTarget.textContent = "";
  }
}
