import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    const storedPartId = window.AdminV2SelectedProductPartId
    const storedTab = this.tabTargets.find((tab) => tab.dataset.partId === storedPartId)
    const tab = storedTab || this.tabTargets[0]

    if (tab) this.activate(tab.dataset.partId)
  }

  select(event) {
    this.activate(event.currentTarget.dataset.partId)
  }

  activate(partId) {
    window.AdminV2SelectedProductPartId = partId

    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.partId === partId
      tab.classList.toggle("border-[var(--g-accent-border)]", active)
      tab.classList.toggle("bg-[var(--g-accent-soft)]", active)
      tab.classList.toggle("text-[var(--g-accent)]", active)
      tab.classList.toggle("border-white/[0.075]", !active)
      tab.classList.toggle("bg-white/[0.035]", !active)
      tab.setAttribute("aria-pressed", active ? "true" : "false")
    })

    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.partId !== partId)
    })
  }
}
