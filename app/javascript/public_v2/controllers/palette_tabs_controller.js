import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    this.show(this.activeIndex)
  }

  select(event) {
    event.preventDefault()
    this.show(Number(event.params.index || 0))
  }

  show(index) {
    this.tabTargets.forEach((tab, tabIndex) => {
      const active = tabIndex === index

      tab.classList.toggle("is-active", active)
      tab.setAttribute("aria-selected", active ? "true" : "false")
    })

    this.panelTargets.forEach((panel, panelIndex) => {
      const active = panelIndex === index

      panel.hidden = !active
      panel.classList.toggle("hidden", !active)
      panel.setAttribute("aria-hidden", active ? "false" : "true")
    })
  }

  get activeIndex() {
    return Math.max(this.tabTargets.findIndex((tab) => tab.classList.contains("is-active")), 0)
  }
}
