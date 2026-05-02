import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit(event) {
    const form = event.target.closest("form")
    if (!form) return

    this.log(`${event.target.dataset.label || "Association"} toggled`)
    form.requestSubmit()
  }

  log(message) {
    document.dispatchEvent(new CustomEvent("admin-v2:log", {
      detail: { level: "info", message }
    }))
  }
}
