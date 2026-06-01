import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "panel"]

  connect() {
    this.closeTimeout = null
  }

  disconnect() {
    if (this.closeTimeout) clearTimeout(this.closeTimeout)
    document.body.classList.remove("overflow-hidden")
  }

  open(event) {
    event.preventDefault()
    if (!this.hasModalTarget || !this.hasPanelTarget) return
    if (this.closeTimeout) clearTimeout(this.closeTimeout)

    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")

    requestAnimationFrame(() => {
      this.modalTarget.classList.remove("opacity-0")
      this.modalTarget.classList.add("opacity-100")
      this.panelTarget.classList.remove("opacity-0", "scale-95", "translate-y-2")
      this.panelTarget.classList.add("opacity-100", "scale-100", "translate-y-0")
    })
  }

  close(event) {
    if (event) event.preventDefault()
    if (!this.hasModalTarget || !this.hasPanelTarget) return

    this.modalTarget.classList.remove("opacity-100")
    this.modalTarget.classList.add("opacity-0")
    this.panelTarget.classList.remove("opacity-100", "scale-100", "translate-y-0")
    this.panelTarget.classList.add("opacity-0", "scale-95", "translate-y-2")

    this.closeTimeout = setTimeout(() => {
      this.modalTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }, this.motionAllowed ? 220 : 0)
  }

  backdropClose(event) {
    if (event.target !== this.modalTarget) return
    this.close(event)
  }

  get motionAllowed() {
    return !window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
