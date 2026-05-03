import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]
  static values = {
    limit: { type: Number, default: 80 }
  }

  connect() {
    this.add("system", "Session feed ready")
    this.boundTurboSubmitStart = (event) => this.handleSubmitStart(event)
    this.boundTurboSubmitEnd = (event) => this.handleSubmitEnd(event)
    this.boundTurboFrameLoad = (event) => this.handleFrameLoad(event)
    this.boundCustomEvent = (event) => this.handleCustomEvent(event)

    document.addEventListener("turbo:submit-start", this.boundTurboSubmitStart)
    document.addEventListener("turbo:submit-end", this.boundTurboSubmitEnd)
    document.addEventListener("turbo:frame-load", this.boundTurboFrameLoad)
    document.addEventListener("admin-v2:log", this.boundCustomEvent)
  }

  disconnect() {
    document.removeEventListener("turbo:submit-start", this.boundTurboSubmitStart)
    document.removeEventListener("turbo:submit-end", this.boundTurboSubmitEnd)
    document.removeEventListener("turbo:frame-load", this.boundTurboFrameLoad)
    document.removeEventListener("admin-v2:log", this.boundCustomEvent)
  }

  handleSubmitStart(event) {
    const form = event.target
    this.add("server", `${form.method.toUpperCase()} ${new URL(form.action).pathname}`)
  }

  handleSubmitEnd(event) {
    const status = event.detail.fetchResponse?.response?.status
    const level = status && status >= 400 ? "error" : "success"
    this.add(level, `Server response ${status || "ok"}`)
  }

  handleFrameLoad(event) {
    this.add("info", `Frame loaded ${event.target.id}`)
  }

  handleCustomEvent(event) {
    this.add(event.detail.level || "info", event.detail.message || "Action")
  }

  add(level, message) {
    const item = document.createElement("li")
    item.className = this.classNameFor(level)
    item.innerHTML = `
      <span class="mt-1 h-1.5 w-1.5 shrink-0 rounded-full" style="background:${this.colorFor(level)}"></span>
      <span class="text-[10px] text-[var(--g-subtle)]">${this.timestamp()}</span>
      <span class="uppercase tracking-wide text-[9px]" style="color:${this.colorFor(level)}">${level}</span>
      <span class="min-w-0 flex-1 truncate text-[11px] text-[var(--g-muted)]">${this.escape(message)}</span>
    `

    this.listTarget.prepend(item)

    while (this.listTarget.children.length > this.limitValue) {
      this.listTarget.lastElementChild.remove()
    }
  }

  classNameFor() {
    return "grid grid-cols-[8px_58px_48px_minmax(0,1fr)] items-start gap-2 border-b border-white/[0.055] px-3 py-2"
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

  timestamp() {
    return new Intl.DateTimeFormat("fr-FR", {
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit"
    }).format(new Date())
  }

  escape(value) {
    const div = document.createElement("div")
    div.textContent = value
    return div.innerHTML
  }
}
