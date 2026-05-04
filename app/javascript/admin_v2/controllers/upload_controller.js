import { Controller } from "@hotwired/stimulus"
import { DirectUpload } from "@rails/activestorage"

export default class extends Controller {
  static targets = ["input", "status", "statusLabel", "spinner", "progress", "progressBar"]
  static values = {
    createUrl: String,
    field: String,
    maxSizeMb: Number,
    acceptedTypes: String
  }

  connect() {
    this.activeUploads = 0
    this.loadedBytes = 0
    this.totalBytes = 0
    this.progressByFile = new Map()
    this.statusTimer = null
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
    const validation = this.validateFile(file)

    if (!validation.valid) {
      this.showIdleStatus(validation.label, "error")
      this.log("error", validation.message, { type: "upload" })
      return
    }

    this.log("server", `Upload started ${file.name}`)
    this.startFile(file)

    const upload = new DirectUpload(file, "/rails/active_storage/direct_uploads", this)
    upload.create((error, blob) => {
      if (error) {
        this.finishFile(file.name)
        this.showIdleStatus("upload failed", "error")
        this.log("error", `Upload failed ${file.name}: ${this.errorMessage(error)}`, { type: "upload" })
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
      .then(async (response) => {
        const html = await response.text()

        if (html.trim()) window.Turbo.renderStreamMessage(html)
        if (!response.ok) throw new Error(`server rejected ${filename} (${response.status})`)

        this.finishFile(filename)
        this.log("success", `Attached ${filename}`, { type: "upload" })
      })
      .catch((error) => {
        this.finishFile(filename)
        this.showIdleStatus("attach failed", "error")
        this.log("error", `Attach failed ${filename}: ${this.errorMessage(error)}`, { type: "upload" })
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

    if (uploading) this.clearStatusTimer()
    this.applyStatusTone("info")

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

  validateFile(file) {
    const maxBytes = this.maxBytes()
    const acceptedTypes = this.acceptedTypes()

    if (maxBytes && file.size > maxBytes) {
      return {
        valid: false,
        label: "too large",
        message: `Upload blocked ${file.name}: file too large (${this.formatBytes(file.size)} / limit ${this.maxSizeMbValue} MB)`
      }
    }

    if (acceptedTypes.length > 0 && file.type && !acceptedTypes.includes(file.type)) {
      return {
        valid: false,
        label: "bad format",
        message: `Upload blocked ${file.name}: unsupported type ${file.type}`
      }
    }

    return { valid: true }
  }

  maxBytes() {
    if (!this.hasMaxSizeMbValue || this.maxSizeMbValue <= 0) return null

    return this.maxSizeMbValue * 1024 * 1024
  }

  acceptedTypes() {
    if (!this.hasAcceptedTypesValue) return []

    return this.acceptedTypesValue.split(",").map((type) => type.trim()).filter(Boolean)
  }

  showIdleStatus(label, level = "info") {
    if (this.activeUploads > 0 || !this.hasStatusTarget) return

    this.clearStatusTimer()
    this.applyStatusTone(level)
    this.statusTarget.classList.remove("hidden")
    this.statusTarget.classList.add("inline-flex")
    if (this.hasSpinnerTarget) this.spinnerTarget.classList.add("hidden")
    if (this.hasProgressTarget) this.progressTarget.classList.add("hidden")
    if (this.hasStatusLabelTarget) this.statusLabelTarget.textContent = label

    this.statusTimer = window.setTimeout(() => {
      this.applyStatusTone("info")
      this.renderState()
    }, 3200)
  }

  applyStatusTone(level) {
    if (!this.hasStatusTarget) return

    const tones = {
      error: {
        borderColor: "rgba(255, 104, 104, 0.36)",
        backgroundColor: "rgba(255, 104, 104, 0.12)",
        color: "var(--g-red)"
      },
      info: {
        borderColor: "var(--g-accent-border)",
        backgroundColor: "var(--g-accent-soft)",
        color: "var(--g-accent)"
      }
    }
    const tone = tones[level] || tones.info

    this.statusTarget.style.borderColor = tone.borderColor
    this.statusTarget.style.backgroundColor = tone.backgroundColor
    this.statusTarget.style.color = tone.color
  }

  clearStatusTimer() {
    if (!this.statusTimer) return

    window.clearTimeout(this.statusTimer)
    this.statusTimer = null
  }

  errorMessage(error) {
    if (!error) return "unknown error"
    if (typeof error === "string") return error

    return error.message || "unknown error"
  }

  formatBytes(bytes) {
    return `${(bytes / 1024 / 1024).toFixed(1)} MB`
  }

  log(level, message, details = {}) {
    document.dispatchEvent(new CustomEvent("admin-v2:log", {
      detail: { source: "upload", type: "upload", level, message, ...details }
    }))
  }
}
