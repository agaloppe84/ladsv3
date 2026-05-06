import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "trigger"]
  static values = { open: Boolean }

  connect() {
    this.sync()
  }

  toggle(event) {
    event.preventDefault()
    this.openValue = !this.openValue
  }

  close() {
    if (!this.openValue) return

    this.openValue = false
  }

  closeOnOutsideClick(event) {
    if (!this.openValue || this.element.contains(event.target)) return

    this.close()
  }

  openValueChanged() {
    this.sync()
  }

  sync() {
    if (!this.hasPanelTarget) return

    this.panelTarget.hidden = !this.openValue
    this.element.classList.toggle("is-open", this.openValue)

    if (this.hasTriggerTarget) {
      this.triggerTarget.setAttribute("aria-expanded", this.openValue ? "true" : "false")
    }
  }
}
