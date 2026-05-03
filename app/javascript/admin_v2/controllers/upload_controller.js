import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "status", "statusLabel", "spinner", "progress", "progressBar"]
  static values = {
    createUrl: String,
    field: String
  }

  connect() {
    this.activeUploads = 0
    this.loadedBytes = 0
    this.totalBytes = 0
    this.progressByFile = new Map()
    this.renderState()
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
    this.startFile(file)

    const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads", this)
    upload.create((error, blob) => {
      if (error) {
        this.finishFile(file.name)
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
        this.finishFile(filename)
        this.log("success", `Attached ${filename}`)
      })
      .catch(() => {
        this.finishFile(filename)
        this.log("error", `Attach failed ${filename}`)
      })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress", (event) => {
      if (!event.lengthComputable) return

      this.loadedBytes = event.loaded
      this.totalBytes = event.total
      this.renderState()
    })
  }

  startFile(file) {
    this.activeUploads += 1
    this.progressByFile.set(file.name, { loaded: 0, total: file.size || 0 })
    this.renderState()
  }

  finishFile(filename) {
    this.progressByFile.delete(filename)
    this.activeUploads = Math.max(this.activeUploads - 1, 0)
    this.loadedBytes = 0
    this.totalBytes = 0
    this.renderState()
  }

  renderState() {
    const uploading = this.activeUploads > 0
    const progress = this.progressPercent()

    if (this.hasStatusTarget) {
      this.statusTarget.classList.toggle("hidden", !uploading)
      this.statusTarget.classList.toggle("inline-flex", uploading)
    }
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.toggle("hidden", !uploading)
    if (this.hasProgressTarget) {
      this.progressTarget.classList.toggle("hidden", !uploading)
      this.progressTarget.classList.toggle("block", uploading)
    }
    if (this.hasProgressBarTarget) this.progressBarTarget.style.width = `${progress}%`
    if (this.hasStatusLabelTarget) {
      this.statusLabelTarget.textContent = this.activeUploads > 1 ? `${this.activeUploads} uploads` : "uploading"
    }
  }

  progressPercent() {
    if (this.totalBytes <= 0) return 8

    return Math.max(8, Math.min(100, Math.round((this.loadedBytes / this.totalBytes) * 100)))
  }

  log(level, message) {
    document.dispatchEvent(new CustomEvent("admin-v2:log", {
      detail: { level, message }
    }))
  }
}
