import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "panel"]

  connect() {
    this.closeTimeout = null
    this.modalEl = this.modalTarget
    this.panelEl = this.panelTarget
    this.originalParent = this.modalEl.parentNode
    this.originalNextSibling = this.modalEl.nextSibling
    this.handleModalClick = (event) => {
      if (event.target === this.modalEl || event.target.closest("[data-palette-modal-close]")) {
        this.close(event)
      }
    }

    document.body.appendChild(this.modalEl)
    this.modalEl.classList.add("hidden")
    this.modalEl.addEventListener("click", this.handleModalClick)
  }

  disconnect() {
    if (this.closeTimeout) clearTimeout(this.closeTimeout)

    this.modalEl.removeEventListener("click", this.handleModalClick)
    document.body.classList.remove("overflow-hidden")

    if (!this.originalParent) return
    if (this.originalNextSibling && this.originalNextSibling.parentNode === this.originalParent) {
      this.originalParent.insertBefore(this.modalEl, this.originalNextSibling)
    } else {
      this.originalParent.appendChild(this.modalEl)
    }
  }

  open(event) {
    event.preventDefault()
    if (!this.modalEl || !this.panelEl) return
    if (this.closeTimeout) clearTimeout(this.closeTimeout)

    this.modalEl.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")

    requestAnimationFrame(() => {
      this.modalEl.classList.remove("opacity-0")
      this.modalEl.classList.add("opacity-100")
      this.panelEl.classList.remove("opacity-0", "scale-95", "translate-y-2")
      this.panelEl.classList.add("opacity-100", "scale-100", "translate-y-0")
    })
  }

  close(event) {
    if (event) event.preventDefault()
    if (!this.modalEl || !this.panelEl) return

    this.modalEl.classList.remove("opacity-100")
    this.modalEl.classList.add("opacity-0")
    this.panelEl.classList.remove("opacity-100", "scale-100", "translate-y-0")
    this.panelEl.classList.add("opacity-0", "scale-95", "translate-y-2")

    this.closeTimeout = setTimeout(() => {
      this.modalEl.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }, this.motionAllowed ? 220 : 0)
  }

  backdropClose(event) {
    if (event.target !== this.modalEl) return
    this.close(event)
  }

  get motionAllowed() {
    return !window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
