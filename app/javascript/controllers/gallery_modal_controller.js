import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "panel", "image"]

  connect() {
    this.closeTimeout = null
    this.overlayEl = this.overlayTarget
    this.panelEl = this.panelTarget
    this.imageEl = this.imageTarget
    this.handleBackdropClick = this.backdropClose.bind(this)
    this.handleCloseClick = (event) => {
      if (!event.target.closest("[data-gallery-modal-close]")) return
      this.close(event)
    }

    this.originalParent = this.overlayEl.parentNode
    this.originalNextSibling = this.overlayEl.nextSibling

    // Keep the modal at the document root so fullscreen positioning is reliable.
    document.body.appendChild(this.overlayEl)
    this.overlayEl.classList.add("hidden")
    this.overlayEl.addEventListener("click", this.handleBackdropClick)
    this.overlayEl.addEventListener("click", this.handleCloseClick)
  }

  disconnect() {
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
    event.preventDefault()

    const url = event.currentTarget.dataset.galleryModalUrlValue
    if (url) this.imageEl.src = url

    if (this.closeTimeout) clearTimeout(this.closeTimeout)

    this.overlayEl.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")

    // Trigger transition on next frame.
    requestAnimationFrame(() => {
      this.overlayEl.classList.remove("opacity-0")
      this.overlayEl.classList.add("opacity-100")
      this.panelEl.classList.remove("opacity-0", "scale-95", "translate-y-2")
      this.panelEl.classList.add("opacity-100", "scale-100", "translate-y-0")
    })
  }

  close(event) {
    if (event) event.preventDefault()

    this.overlayEl.classList.remove("opacity-100")
    this.overlayEl.classList.add("opacity-0")
    this.panelEl.classList.remove("opacity-100", "scale-100", "translate-y-0")
    this.panelEl.classList.add("opacity-0", "scale-95", "translate-y-2")

    this.closeTimeout = setTimeout(() => {
      this.overlayEl.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
      this.imageEl.src = ""
    }, 240)
  }

  backdropClose(event) {
    if (event.target !== this.overlayEl) return
    this.close(event)
  }
}
