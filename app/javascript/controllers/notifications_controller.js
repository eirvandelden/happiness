import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]

  async connect() {
    const registration = await this.reminderRegistration();
    if (!registration) return this.hide();

    if (Notification.permission === 'granted') {
      await this.registerSync(registration);
      this.hide();
    }
  }

  async enable() {
    const registration = await this.reminderRegistration();
    if (!registration) return this.hide();

    const permission = await Notification.requestPermission();
    if (permission !== 'granted') return;
    await this.registerSync(registration);
    this.hide();
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

  hide() {
    this.element.hidden = true;
  }
}
