import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["status", "label", "spinner", "successIcon", "errorIcon"]
  static values = {
    hideDelay: { type: Number, default: 1800 }
  }

  connect() {
    this.hideTimer = null
    this.hide()
  }

  disconnect() {
    this.clearHideTimer()
  }

  saving() {
    this.clearHideTimer()
    this.show("saving")
  }

  complete(event) {
    this.clearHideTimer()
    this.show(event.detail.success ? "saved" : "error")

    this.hideTimer = window.setTimeout(() => this.hide(), this.hideDelayValue)
  }

  show(state) {
    const isSaving = state === "saving"
    const isSaved = state === "saved"
    const isError = state === "error"

    this.statusTarget.classList.remove("hidden", "text-[var(--g-red)]", "border-red-300/25", "bg-red-500/10")
    this.statusTarget.classList.add("inline-flex")
    this.statusTarget.classList.toggle("text-[var(--g-accent)]", !isError)
    this.statusTarget.classList.toggle("border-[var(--g-accent-border)]", !isError)
    this.statusTarget.classList.toggle("bg-[var(--g-accent-soft)]", !isError)
    this.statusTarget.classList.toggle("text-[var(--g-red)]", isError)
    this.statusTarget.classList.toggle("border-red-300/25", isError)
    this.statusTarget.classList.toggle("bg-red-500/10", isError)

    this.spinnerTarget.classList.toggle("hidden", !isSaving)
    this.successIconTarget.classList.toggle("hidden", !isSaved)
    this.errorIconTarget.classList.toggle("hidden", !isError)

    this.labelTarget.textContent = state
  }

  hide() {
    this.statusTarget.classList.add("hidden")
    this.statusTarget.classList.remove("inline-flex")
    this.spinnerTarget.classList.add("hidden")
    this.successIconTarget.classList.add("hidden")
    this.errorIconTarget.classList.add("hidden")
  }

  clearHideTimer() {
    if (!this.hideTimer) return

    window.clearTimeout(this.hideTimer)
    this.hideTimer = null
  }
}
