import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }

  pending() {
    this.element.classList.add("admin-v2-pending")
  }

  complete() {
    this.element.classList.remove("admin-v2-pending")
  }
}
