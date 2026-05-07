import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modeButton"]

  static storageKey = "public-v2-mode"

  connect() {
    const mode = this.storedMode || this.element.dataset.publicV2Mode || "light"
    const normalizedMode = this.applyMode(mode)
    this.syncModeButtons(normalizedMode)
  }

  selectMode(event) {
    const mode = event.currentTarget.dataset.mode
    const normalizedMode = this.applyMode(mode)
    this.storeMode(normalizedMode)
    this.syncModeButtons(normalizedMode)
  }

  applyMode(mode) {
    const normalizedMode = mode === "dark" ? "dark" : "light"

    this.element.dataset.publicV2Mode = normalizedMode
    this.element.classList.toggle("dark", normalizedMode === "dark")
    this.element.style.colorScheme = normalizedMode

    return normalizedMode
  }

  syncModeButtons(mode) {
    const normalizedMode = mode === "dark" ? "dark" : "light"

    this.modeButtonTargets.forEach((button) => {
      const selected = button.dataset.mode === normalizedMode
      button.classList.toggle("is-selected", selected)
      button.setAttribute("aria-pressed", selected ? "true" : "false")
    })
  }

  storeMode(mode) {
    try {
      window.localStorage.setItem(this.constructor.storageKey, mode === "dark" ? "dark" : "light")
    } catch (_error) {
      // Local storage can be unavailable in private contexts.
    }
  }

  get storedMode() {
    try {
      return window.localStorage.getItem(this.constructor.storageKey)
    } catch (_error) {
      return null
    }
  }
}
