import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template"]
  static values = {
    limit: { type: Number, default: 80 }
  }

  connect() {
    this.add({ level: "system", source: "client", type: "session", message: "Session feed ready" })
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
    const method = form.method.toUpperCase()

    this.add({
      level: "server",
      source: "form",
      type: "submit",
      method,
      path: this.pathFor(form.action),
      message: `${method} ${this.pathFor(form.action)}`
    })
  }

  handleSubmitEnd(event) {
    const status = event.detail.fetchResponse?.response?.status
    const level = status && status >= 400 ? "error" : "success"
    const form = event.detail.formSubmission?.formElement

    this.add({
      level,
      source: "server",
      type: "response",
      method: form?.method?.toUpperCase(),
      status: status || "ok",
      message: `Response ${status || "ok"}`
    })
  }

  handleFrameLoad(event) {
    this.add({
      level: "info",
      source: "turbo",
      type: "frame",
      message: event.target.id || "frame loaded"
    })
  }

  handleCustomEvent(event) {
    const detail = event.detail || {}

    this.add({
      level: detail.level || "info",
      source: detail.source || "server",
      type: detail.type || "event",
      method: detail.method,
      path: detail.path,
      status: detail.status,
      resource: detail.resource,
      message: detail.message || "Action"
    })
  }

  add(detail, fallbackMessage) {
    const entry = this.normalizeEntry(detail, fallbackMessage)
    const item = document.createElement("li")
    item.className = this.classNameFor()
    item.innerHTML = `
      <span class="mt-1 h-1.5 w-1.5 shrink-0 rounded-full" style="background:${this.colorFor(entry.level)}"></span>
      <span class="text-[10px] text-[var(--g-subtle)]">${this.timestamp()}</span>
      <span class="truncate uppercase tracking-wide text-[9px] text-[var(--g-faint)]">${this.escape(entry.source)}</span>
      <span class="truncate uppercase tracking-wide text-[9px]" style="color:${this.colorFor(entry.level)}">${this.escape(entry.type)}</span>
      <span class="min-w-0 flex items-center gap-2">
        <span class="min-w-0 flex-1 truncate text-[11px] text-[var(--g-muted)]">${this.escape(entry.message)}</span>
        ${this.metaMarkup(entry)}
      </span>
    `

    this.listTarget.prepend(item)

    while (this.listTarget.children.length > this.limitValue) {
      this.listTarget.lastElementChild.remove()
    }
  }

  normalizeEntry(detail, fallbackMessage) {
    if (typeof detail === "string") {
      return {
        level: detail,
        source: "client",
        type: detail,
        message: fallbackMessage || "Action"
      }
    }

    return {
      level: detail?.level || "info",
      source: detail?.source || "client",
      type: detail?.type || detail?.level || "event",
      method: detail?.method,
      path: detail?.path,
      status: detail?.status,
      resource: detail?.resource,
      message: detail?.message || "Action"
    }
  }

  metaMarkup(entry) {
    const parts = [entry.method, entry.status, entry.resource].filter(Boolean)
    if (parts.length === 0) return ""

    return `<span class="shrink-0 rounded border border-white/[0.06] bg-white/[0.035] px-1.5 py-0.5 font-mono text-[9px] text-[var(--g-subtle)]">${this.escape(parts.join(" "))}</span>`
  }

  classNameFor() {
    return "grid grid-cols-[8px_58px_42px_52px_minmax(0,1fr)] items-start gap-2 border-b border-white/[0.055] px-3 py-2"
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

  pathFor(url) {
    return new URL(url, window.location.href).pathname
  }

  escape(value) {
    const div = document.createElement("div")
    div.textContent = value || ""
    return div.innerHTML
  }
}
