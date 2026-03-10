import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "panel"]

  connect() {
    this.isEnabled = this.hasOverlayTarget && this.hasPanelTarget
    if (!this.isEnabled) return

    this.closeTimeout = null
    this.overlayEl = this.overlayTarget
    this.panelEl = this.panelTarget
    this.handleBackdropClick = this.backdropClose.bind(this)
    this.handleCloseClick = (event) => {
      if (!event.target.closest("[data-rals-modal-close]")) return
      this.close(event)
    }

    this.originalParent = this.overlayEl.parentNode
    this.originalNextSibling = this.overlayEl.nextSibling

    // Keep the modal at the document root so fixed positioning is reliable.
    document.body.appendChild(this.overlayEl)
    this.overlayEl.classList.add("hidden")
    this.overlayEl.addEventListener("click", this.handleBackdropClick)
    this.overlayEl.addEventListener("click", this.handleCloseClick)
  }

  disconnect() {
    if (!this.isEnabled) return

    if (this.closeTimeout) clearTimeout(this.closeTimeout)

    document.body.classList.remove("overflow-hidden")
    this.overlayEl.removeEventListener("click", this.handleBackdropClick)
    this.overlayEl.removeEventListener("click", this.handleCloseClick)

    if (!this.originalParent) return
    if (this.originalNextSibling && this.originalNextSibling.parentNode === this.originalParent) {
      this.originalParent.insertBefore(this.overlayEl, this.originalNextSibling)
    } else {
      this.originalParent.appendChild(this.overlayEl)
    }
  }

  open(event) {
    if (!this.isEnabled) return
    if (event) event.preventDefault()
    if (this.closeTimeout) clearTimeout(this.closeTimeout)

    this.overlayEl.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")

    requestAnimationFrame(() => {
      this.overlayEl.classList.remove("opacity-0")
      this.overlayEl.classList.add("opacity-100")
      this.panelEl.classList.remove("opacity-0", "scale-[0.98]", "translate-y-3")
      this.panelEl.classList.add("opacity-100", "scale-100", "translate-y-0")
    })
  }

  close(event) {
    if (!this.isEnabled) return
    if (event) event.preventDefault()

    this.overlayEl.classList.remove("opacity-100")
    this.overlayEl.classList.add("opacity-0")
    this.panelEl.classList.remove("opacity-100", "scale-100", "translate-y-0")
    this.panelEl.classList.add("opacity-0", "scale-[0.98]", "translate-y-3")

    this.closeTimeout = setTimeout(() => {
      this.overlayEl.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }, 280)
  }

  backdropClose(event) {
    if (!this.isEnabled) return
    if (event.target !== this.overlayEl) return
    this.close(event)
  }
}
