import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { initial: String }

  connect() {
    const initial = this.initialValue || this.tabTargets[0]?.dataset.tabId
    if (initial) this.activate(initial)
  }

  select(event) {
    event.preventDefault()
    this.activate(event.currentTarget.dataset.tabId)
  }

  activate(tabId) {
    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.tabId === tabId
      tab.setAttribute("aria-selected", active ? "true" : "false")

      tab.classList.toggle("bg-orange-50", active)
      tab.classList.toggle("text-orange-500", active)
      tab.classList.toggle("border-orange-200", active)

      tab.classList.toggle("bg-white", !active)
      tab.classList.toggle("text-slate-600", !active)
      tab.classList.toggle("border-slate-200", !active)
    })

    this.panelTargets.forEach((panel) => {
      const active = panel.dataset.panelId === tabId
      panel.classList.toggle("hidden", !active)
      panel.setAttribute("aria-hidden", active ? "false" : "true")
    })
  }
}
