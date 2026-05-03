import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  select(event) {
    const button = event.currentTarget
    const root = document.querySelector(".admin-v2")
    if (!root) return

    root.style.setProperty("--g-font-family", `var(${button.dataset.fontVariable})`)
    this.markSelected(button)

    document.dispatchEvent(new CustomEvent("admin-v2:log", {
      detail: { level: "info", message: `Typography ${button.dataset.label}` }
    }))
  }

  markSelected(selectedButton) {
    this.buttonTargets.forEach((button) => {
      const selected = button === selectedButton
      button.classList.toggle("border-[var(--g-accent-border)]", selected)
      button.classList.toggle("border-white/[0.075]", !selected)
      button.classList.toggle("bg-[var(--g-accent-soft)]", selected)
      button.classList.toggle("text-[var(--g-accent-text)]", selected)
      button.classList.toggle("text-[var(--g-muted)]", !selected)
      button.setAttribute("aria-pressed", selected ? "true" : "false")
    })
  }
}
