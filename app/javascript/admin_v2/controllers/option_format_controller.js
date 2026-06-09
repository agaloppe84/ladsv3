import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  bold(event) {
    event.preventDefault()

    if (!this.hasInputTarget) return

    const input = this.inputTarget
    const inputWasFocused = document.activeElement === input
    const start = inputWasFocused ? input.selectionStart ?? input.value.length : input.value.length
    const end = inputWasFocused ? input.selectionEnd ?? start : start
    const selectedText = input.value.slice(start, end)
    const fallbackText = "texte en gras"
    const textToWrap = selectedText || fallbackText
    const formattedText = `<strong>${textToWrap}</strong>`

    input.focus({ preventScroll: true })
    input.setRangeText(formattedText, start, end, "end")

    const selectionStart = start + "<strong>".length
    const selectionEnd = selectionStart + textToWrap.length
    input.setSelectionRange(selectionStart, selectionEnd)
    input.dispatchEvent(new Event("input", { bubbles: true }))
  }
}
