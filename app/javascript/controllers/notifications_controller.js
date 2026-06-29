import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status"]

  async connect() {
    if (!this.isSupported()) {
      this.element.hidden = true;
      return;
    }
    if (Notification.permission === 'granted') {
      await this.registerSync();
      this.element.hidden = true;
    }
  }

  async enable() {
    const permission = await Notification.requestPermission();
    if (permission !== 'granted') return;
    await this.registerSync();
    this.element.hidden = true;
  }

  async registerSync() {
    const registration = await navigator.serviceWorker.ready;
    if ('periodicSync' in registration) {
      await registration.periodicSync.register('happiness-reminder', {
        minInterval: 4 * 60 * 60 * 1000,
      });
    }
  }

  isSupported() {
    return 'serviceWorker' in navigator && 'Notification' in window;
  }
}
