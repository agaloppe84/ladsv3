import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    url: String,
    param: String
  }

  connect() {
    this.sortable = new Sortable(this.element, {
      animation: 150,
      handle: "[data-admin-v2-sortable-handle]",
      onEnd: () => this.save()
    })
  }

  disconnect() {
    if (this.sortable) this.sortable.destroy()
  }

  save() {
    const token = document.querySelector("meta[name='csrf-token']").content
    const ids = Array.from(this.element.querySelectorAll("[data-sortable-id]")).map((item) => item.dataset.sortableId)
    const body = new FormData()
    ids.forEach((id) => body.append(`${this.paramValue}[]`, id))

    this.log("server", `PATCH ${this.pathForLog()}`)

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "X-CSRF-Token": token,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body
    })
      .then((response) => response.text())
      .then((html) => {
        window.Turbo.renderStreamMessage(html)
        this.log("success", "Order saved")
      })
      .catch(() => this.log("error", "Order save failed"))
  }

  log(level, message) {
    document.dispatchEvent(new CustomEvent("admin-v2:log", {
      detail: { level, message }
    }))
  }

  pathForLog() {
    try {
      return new URL(this.urlValue, window.location.origin).pathname
    } catch (_) {
      return this.urlValue
    }
  }
}
