import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "preview"]
  static values = {
    createUrl: String,
    field: String
  }

  choose(event) {
    event.preventDefault()
    this.inputTarget.click()
  }

  upload(event) {
    Array.from(event.target.files || []).forEach((file) => this.uploadFile(file))
    event.target.value = ""
  }

  uploadFile(file) {
    this.log("server", `Upload started ${file.name}`)
    this.preview(file)

    const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads", this)
    upload.create((error, blob) => {
      if (error) {
        this.log("error", `Upload failed ${file.name}`)
        return
      }

      this.attach(blob.signed_id, file.name)
    })
  }

  attach(signedId, filename) {
    const token = document.querySelector("meta[name='csrf-token']").content
    const body = new FormData()
    body.append(this.fieldValue, signedId)

    fetch(this.createUrlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": token,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body
    })
      .then((response) => response.text())
      .then((html) => {
        window.Turbo.renderStreamMessage(html)
        this.log("success", `Attached ${filename}`)
      })
      .catch(() => this.log("error", `Attach failed ${filename}`))
  }

  preview(file) {
    if (!this.hasPreviewTarget) return

    const item = document.createElement("div")
    item.className = "rounded-lg border border-white/[0.075] bg-white/[0.035] p-3 text-[11px] text-[var(--g-muted)]"
    item.textContent = `${file.name} queued`
    this.previewTarget.prepend(item)
  }

  log(level, message) {
    document.dispatchEvent(new CustomEvent("admin-v2:log", {
      detail: { level, message }
    }))
  }
}
