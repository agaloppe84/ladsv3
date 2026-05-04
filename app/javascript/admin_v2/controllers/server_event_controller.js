import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    level: String,
    message: String,
    source: String,
    type: String,
    method: String,
    path: String,
    status: String,
    resource: String
  }

  connect() {
    document.dispatchEvent(new CustomEvent("admin-v2:log", {
      detail: {
        level: this.levelValue || "info",
        message: this.messageValue || "Server event",
        source: this.sourceValue || "server",
        type: this.typeValue || "server",
        method: this.methodValue,
        path: this.pathValue,
        status: this.statusValue,
        resource: this.resourceValue
      }
    }))

    this.element.remove()
  }
}
