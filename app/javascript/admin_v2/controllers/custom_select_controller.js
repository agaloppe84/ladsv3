import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "input", "panel", "label", "meta", "swatch", "search", "option", "empty"]
  static values = {
    placeholder: String,
    required: { type: Boolean, default: false },
    invalidLabel: String
  }

  connect() {
    this.boundOutsideClick = (event) => this.closeFromOutside(event)
    this.boundFormSubmit = (event) => this.validateBeforeSubmit(event)
    this.form = this.element.closest("form")
    document.addEventListener("pointerdown", this.boundOutsideClick)
    this.form?.addEventListener("submit", this.boundFormSubmit)
  }

  disconnect() {
    document.removeEventListener("pointerdown", this.boundOutsideClick)
    this.form?.removeEventListener("submit", this.boundFormSubmit)
  }

  toggle() {
    this.panelTarget.classList.contains("hidden") ? this.open() : this.close()
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.clearFilter()

    if (this.hasSearchTarget) {
      window.requestAnimationFrame(() => this.searchTarget.focus())
    }
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
  }

  closeFromOutside(event) {
    if (this.panelTarget.classList.contains("hidden")) return
    if (this.element.contains(event.target)) return

    this.close()
  }

  select(event) {
    event.preventDefault()
    this.selectOption(event.currentTarget)
  }

  selectFirst(event) {
    event.preventDefault()
    const option = this.optionTargets.find((candidate) => !candidate.classList.contains("hidden"))
    if (!option) return

    this.selectOption(option)
  }

  selectOption(option) {
    const value = option.dataset.value || ""
    const label = option.dataset.displayLabel || option.dataset.label || this.placeholderValue
    const meta = option.dataset.displayMeta || ""
    const swatch = option.dataset.swatch || ""

    this.inputTarget.value = value
    this.labelTarget.textContent = label
    this.metaTarget.textContent = meta
    this.metaTarget.classList.toggle("hidden", meta.length === 0)
    this.swatchTarget.classList.toggle("hidden", swatch.length === 0)
    if (swatch.length > 0) this.swatchTarget.style.backgroundColor = swatch

    this.clearInvalid()
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.close()
  }

  validateBeforeSubmit(event) {
    if (!this.requiredValue || this.inputTarget.value) return

    event.preventDefault()
    event.stopImmediatePropagation()
    this.markInvalid()
    this.open()
  }

  filter() {
    const query = this.hasSearchTarget ? this.searchTarget.value.trim().toLowerCase() : ""
    let visibleCount = 0

    this.optionTargets.forEach((option) => {
      const visible = query.length === 0 || (option.dataset.keywords || "").includes(query)
      option.classList.toggle("hidden", !visible)
      if (visible) visibleCount += 1
    })

    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", visibleCount > 0)
  }

  clearFilter() {
    if (this.hasSearchTarget) this.searchTarget.value = ""
    this.filter()
  }

  markInvalid() {
    this.buttonTarget.classList.add("border-red-300/35", "bg-red-500/10", "text-[var(--g-red)]")
    this.labelTarget.textContent = this.invalidLabelValue || this.placeholderValue
  }

  clearInvalid() {
    this.buttonTarget.classList.remove("border-red-300/35", "bg-red-500/10", "text-[var(--g-red)]")
  }
}
