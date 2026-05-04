import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "input",
    "toggle",
    "panel",
    "monthLabel",
    "days",
    "displayDate",
    "displayTime",
    "hourLabel",
    "minuteLabel",
    "dirtyBadge",
    "applyButton"
  ]

  static values = {
    selected: String,
    minuteStep: { type: Number, default: 15 }
  }

  connect() {
    this.boundOutsideClick = (event) => this.closeFromOutside(event)
    this.boundBeforeSubmit = () => {
      if (this.dirty) this.commit(false)
    }

    const initialValue = this.inputTarget.value || this.selectedValue
    this.selectedDate = this.parseValue(initialValue)
    this.draftDate = this.copyDate(this.selectedDate) || this.roundToStep(new Date())
    this.viewYear = this.draftDate.getFullYear()
    this.viewMonth = this.draftDate.getMonth()
    this.dirty = false

    this.inputTarget.closest("form")?.addEventListener("submit", this.boundBeforeSubmit)
    document.addEventListener("pointerdown", this.boundOutsideClick)
    this.render()
  }

  disconnect() {
    this.inputTarget.closest("form")?.removeEventListener("submit", this.boundBeforeSubmit)
    document.removeEventListener("pointerdown", this.boundOutsideClick)
  }

  toggle() {
    this.panelTarget.classList.toggle("hidden")
    this.toggleTarget.setAttribute("aria-expanded", this.panelTarget.classList.contains("hidden") ? "false" : "true")
  }

  previousMonth() {
    this.viewMonth -= 1
    if (this.viewMonth < 0) {
      this.viewMonth = 11
      this.viewYear -= 1
    }
    this.renderCalendar()
  }

  nextMonth() {
    this.viewMonth += 1
    if (this.viewMonth > 11) {
      this.viewMonth = 0
      this.viewYear += 1
    }
    this.renderCalendar()
  }

  selectDay(event) {
    const date = this.parseDate(event.currentTarget.dataset.date)
    this.draftDate = new Date(
      date.getFullYear(),
      date.getMonth(),
      date.getDate(),
      this.draftDate.getHours(),
      this.draftDate.getMinutes()
    )
    this.viewYear = this.draftDate.getFullYear()
    this.viewMonth = this.draftDate.getMonth()
    this.markDirty()
    this.render()
  }

  adjustHour(event) {
    const step = Number.parseInt(event.currentTarget.dataset.step, 10)
    this.draftDate.setHours((this.draftDate.getHours() + step + 24) % 24)
    this.markDirty()
    this.render()
  }

  adjustMinute(event) {
    const step = Number.parseInt(event.currentTarget.dataset.step, 10) * this.minuteStepValue
    this.draftDate = new Date(this.draftDate.getTime() + step * 60 * 1000)
    this.viewYear = this.draftDate.getFullYear()
    this.viewMonth = this.draftDate.getMonth()
    this.markDirty()
    this.render()
  }

  setToday() {
    const today = new Date()
    this.draftDate = new Date(
      today.getFullYear(),
      today.getMonth(),
      today.getDate(),
      this.draftDate.getHours(),
      this.draftDate.getMinutes()
    )
    this.viewYear = this.draftDate.getFullYear()
    this.viewMonth = this.draftDate.getMonth()
    this.markDirty()
    this.render()
  }

  setNow() {
    this.draftDate = this.roundToStep(new Date())
    this.viewYear = this.draftDate.getFullYear()
    this.viewMonth = this.draftDate.getMonth()
    this.markDirty()
    this.render()
  }

  apply(event) {
    event.preventDefault()
    this.commit(true)
    this.close()
  }

  closeFromOutside(event) {
    if (this.panelTarget.classList.contains("hidden")) return
    if (this.element.contains(event.target)) return

    this.close()
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this.toggleTarget.setAttribute("aria-expanded", "false")
  }

  commit(notify = true) {
    if (!this.draftDate) return

    const previousValue = this.inputTarget.value
    const nextValue = this.formatValue(this.draftDate)
    this.inputTarget.value = nextValue
    this.selectedDate = this.copyDate(this.draftDate)
    this.dirty = false
    this.render()

    if (notify && previousValue !== nextValue) {
      this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }
  }

  markDirty() {
    this.dirty = true
  }

  render() {
    this.renderDisplay()
    this.renderTime()
    this.renderCalendar()
    this.renderDirtyState()
  }

  renderDisplay() {
    const displayDate = this.dirty ? this.draftDate : this.selectedDate

    this.displayDateTarget.textContent = displayDate ? this.formatDisplayDate(displayDate) : "Non défini"
    this.displayTimeTarget.textContent = displayDate ? this.formatDisplayTime(displayDate) : "--:--"
  }

  renderTime() {
    this.hourLabelTarget.textContent = this.pad(this.draftDate.getHours())
    this.minuteLabelTarget.textContent = this.pad(this.draftDate.getMinutes())
  }

  renderDirtyState() {
    this.dirtyBadgeTarget.classList.toggle("hidden", !this.dirty)
    this.applyButtonTarget.classList.toggle("bg-[var(--g-accent)]", this.dirty)
    this.applyButtonTarget.classList.toggle("text-white", this.dirty)
    this.applyButtonTarget.classList.toggle("bg-[var(--g-accent-soft)]", !this.dirty)
    this.applyButtonTarget.classList.toggle("text-[var(--g-accent)]", !this.dirty)
  }

  renderCalendar() {
    const monthDate = new Date(this.viewYear, this.viewMonth, 1)
    this.monthLabelTarget.textContent = new Intl.DateTimeFormat("fr-FR", {
      month: "long",
      year: "numeric"
    }).format(monthDate)

    this.daysTarget.innerHTML = ""

    const start = this.calendarStart(monthDate)
    for (let index = 0; index < 42; index += 1) {
      const date = new Date(start)
      date.setDate(start.getDate() + index)
      this.daysTarget.appendChild(this.dayButton(date))
    }
  }

  dayButton(date) {
    const button = document.createElement("button")
    button.type = "button"
    button.dataset.date = this.formatDate(date)
    button.dataset.action = "date-time-picker#selectDay"
    button.textContent = date.getDate().toString()

    const inMonth = date.getMonth() === this.viewMonth
    const selected = this.sameDay(date, this.draftDate)
    const today = this.sameDay(date, new Date())

    button.className = [
      "admin-v2-focus flex h-8 items-center justify-center rounded-lg border text-[11px] font-semibold transition",
      selected ? "border-[var(--g-accent-border)] bg-[var(--g-accent-soft)] text-[var(--g-accent)]" : "border-transparent bg-transparent",
      !selected && today ? "border-white/[0.16] text-[var(--g-text)]" : "",
      !selected && !today && inMonth ? "text-[var(--g-muted)] hover:border-white/[0.075] hover:bg-white/[0.035] hover:text-[var(--g-text)]" : "",
      !selected && !today && !inMonth ? "text-[var(--g-faint)] opacity-55 hover:border-white/[0.075] hover:bg-white/[0.025]" : ""
    ].join(" ")

    return button
  }

  calendarStart(monthDate) {
    const start = new Date(monthDate)
    const mondayOffset = (start.getDay() + 6) % 7
    start.setDate(start.getDate() - mondayOffset)
    return start
  }

  parseValue(value) {
    if (!value) return null

    const match = value.match(/^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2})/)
    if (!match) return null

    return new Date(
      Number.parseInt(match[1], 10),
      Number.parseInt(match[2], 10) - 1,
      Number.parseInt(match[3], 10),
      Number.parseInt(match[4], 10),
      Number.parseInt(match[5], 10)
    )
  }

  parseDate(value) {
    const [year, month, day] = value.split("-").map((part) => Number.parseInt(part, 10))
    return new Date(year, month - 1, day)
  }

  formatValue(date) {
    return `${this.formatDate(date)}T${this.pad(date.getHours())}:${this.pad(date.getMinutes())}`
  }

  formatDate(date) {
    return `${date.getFullYear()}-${this.pad(date.getMonth() + 1)}-${this.pad(date.getDate())}`
  }

  formatDisplayDate(date) {
    return new Intl.DateTimeFormat("fr-FR", {
      day: "2-digit",
      month: "short",
      year: "numeric"
    }).format(date)
  }

  formatDisplayTime(date) {
    return `${this.pad(date.getHours())}:${this.pad(date.getMinutes())}`
  }

  roundToStep(date) {
    const rounded = new Date(date)
    const step = this.minuteStepValue || 15
    rounded.setSeconds(0, 0)
    rounded.setMinutes(Math.round(rounded.getMinutes() / step) * step)
    return rounded
  }

  copyDate(date) {
    return date ? new Date(date.getTime()) : null
  }

  sameDay(first, second) {
    if (!first || !second) return false

    return first.getFullYear() === second.getFullYear() &&
      first.getMonth() === second.getMonth() &&
      first.getDate() === second.getDate()
  }

  pad(value) {
    return value.toString().padStart(2, "0")
  }
}
