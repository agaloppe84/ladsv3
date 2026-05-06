import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "panel", "accordionTrigger", "accordionPanel"]
  static values = { activeIndex: Number, initialIndex: Number }

  connect() {
    if (!this.hasActiveIndexValue) {
      this.activeIndexValue = this.hasInitialIndexValue ? this.initialIndexValue : 0
    }

    this.sync()
  }

  select(event) {
    event.preventDefault()
    this.activeIndexValue = Number(event.params.index)
  }

  toggle(event) {
    event.preventDefault()
    const index = Number(event.params.index)
    this.activeIndexValue = this.activeIndexValue === index ? -1 : index
  }

  activeIndexValueChanged() {
    this.sync()
  }

  sync() {
    this.syncFocus()
    this.syncAccordion()
  }

  syncFocus() {
    this.triggerTargets.forEach((trigger, index) => {
      const active = index === this.activeIndexValue
      trigger.classList.toggle("is-active", active)
      trigger.setAttribute("aria-selected", active ? "true" : "false")
    })

    this.panelTargets.forEach((panel, index) => {
      const active = index === this.activeIndexValue
      panel.hidden = !active
    })
  }

  syncAccordion() {
    this.accordionTriggerTargets.forEach((trigger, index) => {
      const active = index === this.activeIndexValue
      trigger.classList.toggle("is-active", active)
      trigger.setAttribute("aria-expanded", active ? "true" : "false")
    })

    this.accordionPanelTargets.forEach((panel, index) => {
      panel.hidden = index !== this.activeIndexValue
    })
  }
}
