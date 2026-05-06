import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modeButton", "accentButton", "fontButton"]

  connect() {
    this.applyMode(this.element.dataset.publicV2Mode || "light")
    this.applyFont(this.element.dataset.publicV2Font || "sans")
  }

  selectMode(event) {
    this.applyMode(event.currentTarget.dataset.mode)
    this.markSelected(this.modeButtonTargets, event.currentTarget)
  }

  selectAccent(event) {
    const button = event.currentTarget
    this.element.style.setProperty("--p-accent-rgb", button.dataset.rgb)
    if (button.dataset.hex) {
      this.element.style.setProperty("--p-accent", button.dataset.hex)
    }
    this.element.style.setProperty("--p-accent-text", button.dataset.text)
    this.element.style.setProperty("--pv2-accent-rgb", button.dataset.rgb)
    if (button.dataset.hex) {
      this.element.style.setProperty("--pv2-accent", button.dataset.hex)
    }
    this.element.style.setProperty("--pv2-accent-text", button.dataset.text)
    if (button.dataset.kind) {
      this.element.dataset.publicV2AccentKind = button.dataset.kind
    }
    this.element.querySelectorAll(".pv2-shell").forEach((shell) => {
      shell.style.setProperty("--pv2-accent-rgb", button.dataset.rgb)
      if (button.dataset.hex) {
        shell.style.setProperty("--pv2-accent", button.dataset.hex)
      }
      shell.style.setProperty("--pv2-accent-text", button.dataset.text)
    })
    this.markSelected(this.accentButtonTargets, button)
  }

  selectFont(event) {
    this.applyFont(event.currentTarget.dataset.font)
    this.markSelected(this.fontButtonTargets, event.currentTarget)
  }

  applyMode(mode) {
    this.element.dataset.publicV2Mode = mode
  }

  applyFont(font) {
    this.element.dataset.publicV2Font = font
    const variable = font === "mono" ? "var(--p-font-mono)" : "var(--p-font-sans)"
    this.element.style.setProperty("--p-font-family", variable)
  }

  markSelected(buttons, selectedButton) {
    buttons.forEach((button) => {
      const selected = button === selectedButton
      button.classList.toggle("is-selected", selected)
      button.setAttribute("aria-pressed", selected ? "true" : "false")
    })
  }
}
