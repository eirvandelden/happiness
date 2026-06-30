import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "label"]
  static values = { labels: Object }

  connect() {
    this.updateLabel()
  }

  updateLabel() {
    this.labelTarget.textContent = this.labelsValue[this.inputTarget.value]
  }
}
