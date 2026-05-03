import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.pending = false
    this.lastSubmittedElement = null
    this.lastSubmittedValue = null
  }

  remember(event) {
    event.target.dataset.autosaveInitialValue = this.valueFor(event.target)
  }

  submitIfChanged(event) {
    const currentValue = this.valueFor(event.target)
    const initialValue = event.target.dataset.autosaveInitialValue ?? event.target.defaultValue

    if (currentValue === initialValue) return

    this.submit(event)
  }

  submit(event) {
    if (this.pending) return

    const form = event.target.closest("form")
    if (!form) return

    this.pending = true
    this.lastSubmittedElement = event.target
    this.lastSubmittedValue = this.valueFor(event.target)
    form.requestSubmit()
  }

  complete(event) {
    if (event.detail.success && this.lastSubmittedElement) {
      this.lastSubmittedElement.dataset.autosaveInitialValue = this.lastSubmittedValue
    }

    this.pending = false
    this.lastSubmittedElement = null
    this.lastSubmittedValue = null
  }

  valueFor(element) {
    if (element.type === "checkbox") return element.checked ? "1" : "0"
    if (element.type === "radio") return element.checked ? element.value : ""

    return element.value
  }
}
