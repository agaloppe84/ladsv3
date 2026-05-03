import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "button", "status", "progress"]
  static values = {
    interval: { type: Number, default: 360 },
    lines: Array
  }

  connect() {
    this.index = 0
    this.timers = []
    this.buttonTarget.disabled = true
    this.statusTarget.textContent = "initializing"
    this.progressTarget.style.width = "0%"

    this.timers.push(window.setTimeout(() => this.tick(), 220))
  }

  disconnect() {
    this.timers.forEach((timer) => window.clearTimeout(timer))
    this.timers = []
  }

  tick() {
    const line = this.linesValue[this.index]
    if (!line) {
      this.complete()
      return
    }

    this.append(line)
    this.index += 1
    this.progressTarget.style.width = `${Math.round((this.index / Math.max(this.linesValue.length, 1)) * 100)}%`

    this.timers.push(window.setTimeout(() => this.tick(), this.intervalValue))
  }

  append(line) {
    const level = line.level || "info"
    const message = line.message || "ready"
    const item = document.createElement("li")

    item.className = "grid grid-cols-[8px_72px_minmax(0,1fr)] items-start gap-2 border-b border-white/[0.055] px-2 py-2 last:border-b-0"

    const dot = document.createElement("span")
    dot.className = "mt-1.5 h-1.5 w-1.5 rounded-full"
    dot.style.background = this.colorFor(level)

    const label = document.createElement("span")
    label.className = "text-[9px] uppercase tracking-[0.16em]"
    label.style.color = this.colorFor(level)
    label.textContent = level

    const content = document.createElement("span")
    content.className = "min-w-0 truncate text-[11px] text-[var(--g-muted)]"
    content.textContent = message

    item.append(dot, label, content)
    this.listTarget.append(item)

    document.dispatchEvent(new CustomEvent("admin-v2:log", {
      detail: { level, message }
    }))
  }

  complete() {
    this.statusTarget.textContent = "interface ready"
    this.buttonTarget.disabled = false
    this.buttonTarget.focus()
  }

  dismiss() {
    this.element.remove()
  }

  colorFor(level) {
    return {
      success: "var(--g-green)",
      info: "var(--g-accent)",
      server: "var(--g-cyan)",
      warning: "var(--g-amber)",
      error: "var(--g-red)",
      system: "var(--g-faint)"
    }[level] || "var(--g-muted)"
  }
}
