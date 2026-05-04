import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel", "icon"]

  connect() {
    this.setExpanded(this.expanded)
  }

  toggle() {
    this.setExpanded(!this.expanded)
  }

  setExpanded(expanded) {
    this.buttonTarget.setAttribute("aria-expanded", expanded ? "true" : "false")
    this.panelTarget.classList.toggle("hidden", !expanded)
    if (this.hasIconTarget) this.iconTarget.classList.toggle("rotate-180", expanded)
  }

  get expanded() {
    return this.buttonTarget.getAttribute("aria-expanded") === "true"
  }
}
