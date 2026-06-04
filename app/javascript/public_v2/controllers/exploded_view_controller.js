import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "part", "panel"]
  static values = { activeId: String }

  connect() {
    if (!this.activeIdValue) this.activeIdValue = this.firstPartId
    this.sync()
  }

  select(event) {
    event.preventDefault()

    const partId = event.currentTarget.dataset.partId
    if (!partId) return

    this.activeIdValue = partId
  }

  selectKey(event) {
    if (event.key !== "Enter" && event.key !== " ") return

    this.select(event)
  }

  activeIdValueChanged() {
    this.sync()
  }

  sync() {
    if (!this.activeIdValue) return

    this.element.classList.add("has-active")
    const relatedPartIds = this.relatedPartIds

    this.triggerTargets.forEach((trigger) => {
      const active = trigger.dataset.partId === this.activeIdValue

      trigger.classList.toggle("is-active", active)
      trigger.setAttribute("aria-pressed", active ? "true" : "false")
      trigger.setAttribute("aria-current", active ? "true" : "false")
    })

    this.partTargets.forEach((part) => {
      const active = part.dataset.partId === this.activeIdValue
      const related = relatedPartIds.has(part.dataset.partId)

      part.classList.toggle("is-active", active)
      part.classList.toggle("is-related", !active && related)
      part.setAttribute("aria-pressed", active ? "true" : "false")
    })

    this.panelTargets.forEach((panel) => {
      const active = panel.dataset.partId === this.activeIdValue

      panel.hidden = !active
      panel.classList.toggle("is-active", active)
      panel.setAttribute("aria-hidden", active ? "false" : "true")
    })
  }

  get firstPartId() {
    return this.triggerTargets[0]?.dataset.partId || this.partTargets[0]?.dataset.partId || ""
  }

  get relatedPartIds() {
    const relatedIds = new Set()

    this.partTargets
      .filter((part) => part.dataset.partId === this.activeIdValue)
      .forEach((part) => {
        const ids = (part.dataset.relatedPartIds || "").split(/\s+/).filter(Boolean)

        ids.forEach((id) => relatedIds.add(id))
      })

    return relatedIds
  }
}
