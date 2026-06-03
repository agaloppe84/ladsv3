import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "status", "submit", "submitLabel"]

  connect() {
    this.touchedFields = new Set()
    this.fieldTargets.forEach((field) => {
      if (field.closest(".pv2-quote-field")?.classList.contains("is-invalid")) {
        this.touchedFields.add(field.name)
      }
    })
    this.validate()
  }

  markTouched(event) {
    const field = this.fieldFromEvent(event)
    if (!field) return

    this.touchedFields.add(field.name)
    this.validate()
  }

  validate() {
    const valid = this.fieldTargets.every((field) => this.validateField(field))

    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = !valid
      this.submitTarget.classList.toggle("is-ready", valid)
    }

    if (this.hasStatusTarget) {
      this.statusTarget.textContent = valid ? "Pret a envoyer." : "Completez les champs requis."
    }

    return valid
  }

  submit(event) {
    this.fieldTargets.forEach((field) => this.touchedFields.add(field.name))

    if (!this.validate()) {
      event.preventDefault()
      this.focusFirstInvalidField()
      return
    }

    if (this.hasSubmitTarget) this.submitTarget.disabled = true
    if (this.hasSubmitLabelTarget) this.submitLabelTarget.textContent = "Envoi en cours..."
  }

  validateField(field) {
    const value = (field.value || "").trim()
    const kind = field.dataset.kind || field.type || "text"
    let message = ""

    if (field.dataset.required === "true" && value.length === 0) {
      message = field.dataset.errorRequired || "Ce champ est requis."
    } else if (kind === "email" && !this.validEmail(value)) {
      message = field.dataset.errorEmail || "Email invalide."
    } else if (kind === "phone" && !this.validPhone(value)) {
      message = field.dataset.errorPhone || "Telephone invalide."
    }

    this.updateFieldState(field, message)

    return message.length === 0
  }

  updateFieldState(field, message) {
    const wrapper = field.closest(".pv2-quote-field")
    const error = wrapper?.querySelector("[data-quote-form-field-error]")
    const shouldShow = message.length > 0 && this.touchedFields.has(field.name)

    wrapper?.classList.toggle("is-invalid", shouldShow)
    field.setAttribute("aria-invalid", shouldShow ? "true" : "false")

    if (error) {
      error.textContent = shouldShow ? message : ""
    }
  }

  focusFirstInvalidField() {
    const invalidField = this.fieldTargets.find((field) => field.getAttribute("aria-invalid") === "true")
    if (!invalidField) return

    const customSelectButton = invalidField.closest(".pv2-quote-product-select")?.querySelector("button")
    ;(customSelectButton || invalidField).focus()
  }

  fieldFromEvent(event) {
    if (event.target?.matches?.("[data-quote-form-target~='field']")) return event.target

    return event.target?.closest?.("[data-quote-form-target~='field']")
  }

  validEmail(value) {
    if (value.length === 0) return false

    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
  }

  validPhone(value) {
    return value.replace(/\D/g, "").length >= 10
  }
}
