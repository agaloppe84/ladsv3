import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "title", "message", "body", "confirmButton", "cancelButton"]

  connect() {
    this.pendingResolve = null
    this.boundKeydown = (event) => this.handleKeydown(event)
    window.AdminV2ConfirmDialog = this
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundKeydown)
    if (window.AdminV2ConfirmDialog === this) window.AdminV2ConfirmDialog = null
  }

  request(options = {}) {
    if (this.pendingResolve) this.resolve(false)

    this.titleTarget.textContent = options.title || "Confirmer cette action"
    this.messageTarget.textContent = options.message || "Cette action est irreversible."
    this.bodyTarget.textContent = options.body || "Verifie le contexte avant de confirmer."
    this.confirmButtonTarget.textContent = options.action || "Confirmer"

    this.open()

    return new Promise((resolve) => {
      this.pendingResolve = resolve
    })
  }

  confirm() {
    this.resolve(true)
  }

  cancel() {
    this.resolve(false)
  }

  open() {
    this.dialogTarget.classList.remove("hidden")
    this.dialogTarget.classList.add("flex")
    document.addEventListener("keydown", this.boundKeydown)
    window.requestAnimationFrame(() => this.cancelButtonTarget.focus())
  }

  close() {
    this.dialogTarget.classList.add("hidden")
    this.dialogTarget.classList.remove("flex")
    document.removeEventListener("keydown", this.boundKeydown)
  }

  resolve(value) {
    if (!this.pendingResolve) return

    const resolve = this.pendingResolve
    this.pendingResolve = null
    this.close()
    resolve(value)
  }

  handleKeydown(event) {
    if (event.key === "Escape") this.cancel()
  }
}
