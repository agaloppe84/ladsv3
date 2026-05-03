import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "query"]
  static values = {
    delay: { type: Number, default: 300 },
    minLength: { type: Number, default: 2 }
  }

  connect() {
    this.timer = null
  }

  disconnect() {
    this.clearTimer()
  }

  queue() {
    this.clearTimer()

    const query = this.hasQueryTarget ? this.queryTarget.value.trim() : ""
    if (query.length > 0 && query.length < this.minLengthValue) return

    this.timer = window.setTimeout(() => this.submit(), this.delayValue)
  }

  submit() {
    this.clearTimer()
    const form = this.hasFormTarget ? this.formTarget : this.element
    form.requestSubmit()
  }

  clearTimer() {
    if (!this.timer) return

    window.clearTimeout(this.timer)
    this.timer = null
  }
}
