import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  select(event) {
    const button = event.currentTarget
    const root = document.querySelector(".admin-v2")
    if (!root) return

    root.style.setProperty("--g-accent-rgb", button.dataset.rgb)
    root.style.setProperty("--g-accent-text", button.dataset.text)
    this.markSelected(button)

    document.dispatchEvent(new CustomEvent("admin-v2:log", {
      detail: { level: "info", message: `Accent theme ${button.dataset.label}` }
    }))
  }

  markSelected(selectedButton) {
    this.buttonTargets.forEach((button) => {
      const selected = button === selectedButton
      button.classList.toggle("border-[var(--g-accent-border)]", selected)
      button.classList.toggle("border-white/[0.075]", !selected)
      button.classList.toggle("bg-[var(--g-accent-soft)]", selected)
      button.setAttribute("aria-pressed", selected ? "true" : "false")
    })
  }
}
