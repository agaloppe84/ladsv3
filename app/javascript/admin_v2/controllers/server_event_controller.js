import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    level: String,
    message: String
  }

  connect() {
    document.dispatchEvent(new CustomEvent("admin-v2:log", {
      detail: {
        level: this.levelValue || "info",
        message: this.messageValue || "Server event"
      }
    }))

    this.element.remove()
  }
}
