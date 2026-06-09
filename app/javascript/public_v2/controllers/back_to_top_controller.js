import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]

  connect() {
    this.pendingScrollFrame = null
    this.scrollHandler = () => this.queueVisibilityUpdate()
    this.resizeHandler = () => this.queueVisibilityUpdate()

    this.setVisible(false)
    window.addEventListener("scroll", this.scrollHandler, { passive: true })
    window.addEventListener("resize", this.resizeHandler, { passive: true })
    this.queueVisibilityUpdate()
  }

  disconnect() {
    window.removeEventListener("scroll", this.scrollHandler)
    window.removeEventListener("resize", this.resizeHandler)
    if (this.pendingScrollFrame) cancelAnimationFrame(this.pendingScrollFrame)
  }

  scrollToTop(event) {
    event.preventDefault()

    window.scrollTo({
      top: 0,
      behavior: this.motionAllowed ? "smooth" : "auto"
    })
  }

  queueVisibilityUpdate() {
    if (this.pendingScrollFrame) return

    this.pendingScrollFrame = requestAnimationFrame(() => {
      this.pendingScrollFrame = null
      this.setVisible(this.scrollProgress >= 0.25)
    })
  }

  setVisible(visible) {
    if (!this.hasButtonTarget) return

    this.buttonTarget.classList.toggle("is-visible", visible)
    this.buttonTarget.setAttribute("aria-hidden", visible ? "false" : "true")
    this.buttonTarget.tabIndex = visible ? 0 : -1
  }

  get motionAllowed() {
    return !window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  get scrollProgress() {
    const scrollableHeight = document.documentElement.scrollHeight - window.innerHeight
    if (scrollableHeight <= 0) return 0

    return window.scrollY / scrollableHeight
  }
}
