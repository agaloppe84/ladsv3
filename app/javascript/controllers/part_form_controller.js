import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "code"]

  markManualEdit() {
    this.codeTarget.dataset.manual = "true"
  }

  syncCode() {
    if (this.codeTarget.dataset.manual === "true") return

    const normalized = this.labelTarget.value
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "_")
      .replace(/^_+|_+$/g, "")

    this.codeTarget.value = normalized
  }
}
