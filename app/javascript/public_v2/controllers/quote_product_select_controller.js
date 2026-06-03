import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "empty", "input", "label", "meta", "option", "panel", "search"]
  static values = {
    placeholder: String
  }

  connect() {
    this.closeFromOutside = this.closeFromOutside.bind(this)
    document.addEventListener("pointerdown", this.closeFromOutside)
  }

  disconnect() {
    document.removeEventListener("pointerdown", this.closeFromOutside)
  }

  toggle() {
    this.panelTarget.hidden ? this.open() : this.close()
  }

  open() {
    this.panelTarget.hidden = false
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.clearFilter()

    if (this.hasSearchTarget) {
      window.requestAnimationFrame(() => this.searchTarget.focus())
    }
  }

  close() {
    this.panelTarget.hidden = true
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  closeFromOutside(event) {
    if (this.panelTarget.hidden || this.element.contains(event.target)) return

    this.close()
  }

  select(event) {
    event.preventDefault()
    this.selectOption(event.currentTarget)
  }

  selectFirst(event) {
    event.preventDefault()
    const option = this.optionTargets.find((candidate) => !candidate.hidden)
    if (!option) return

    this.selectOption(option)
  }

  selectOption(option) {
    const value = option.dataset.value || ""
    const label = option.dataset.label || this.placeholderValue
    const meta = option.dataset.meta || ""

    this.inputTarget.value = value
    this.labelTarget.textContent = label
    this.metaTarget.textContent = meta
    this.metaTarget.classList.toggle("is-hidden", meta.length === 0)
    this.element.classList.remove("is-invalid")

    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.close()
  }

  filter() {
    const query = this.hasSearchTarget ? this.searchTarget.value.trim().toLowerCase() : ""
    let visibleCount = 0

    this.optionTargets.forEach((option) => {
      const visible = query.length === 0 || (option.dataset.keywords || "").includes(query)
      option.hidden = !visible
      if (visible) visibleCount += 1
    })

    if (this.hasEmptyTarget) this.emptyTarget.hidden = visibleCount > 0
  }

  clearFilter() {
    if (this.hasSearchTarget) this.searchTarget.value = ""
    this.filter()
  }
}
