import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "slide", "dot"]
  static values = { initialIndex: Number }

  connect() {
    this.activeIndex = this.initialIndex
    this.syncFrame = null
    this.scrollHandler = () => this.queueSync()
    this.resizeHandler = () => this.scrollToIndex(this.activeIndex, { behavior: "auto" })

    if (this.hasTrackTarget) this.trackTarget.addEventListener("scroll", this.scrollHandler, { passive: true })
    window.addEventListener("resize", this.resizeHandler)

    this.setActive(this.activeIndex)
    if (this.activeIndex > 0) {
      requestAnimationFrame(() => this.scrollToIndex(this.activeIndex, { behavior: "auto" }))
    }
  }

  disconnect() {
    if (this.hasTrackTarget) this.trackTarget.removeEventListener("scroll", this.scrollHandler)
    window.removeEventListener("resize", this.resizeHandler)
    if (this.syncFrame) cancelAnimationFrame(this.syncFrame)
  }

  goTo(event) {
    event.preventDefault()
    this.scrollToIndex(Number(event.params.index))
  }

  previous(event) {
    if (event) event.preventDefault()
    this.scrollToIndex(this.activeIndex - 1)
  }

  next(event) {
    if (event) event.preventDefault()
    this.scrollToIndex(this.activeIndex + 1)
  }

  queueSync() {
    if (this.syncFrame) cancelAnimationFrame(this.syncFrame)

    this.syncFrame = requestAnimationFrame(() => {
      this.syncFrame = null
      this.syncFromScroll()
    })
  }

  syncFromScroll() {
    if (!this.hasTrackTarget || this.slideTargets.length === 0) return

    const trackCenter = this.trackTarget.scrollLeft + this.trackTarget.clientWidth / 2
    let closestIndex = 0
    let closestDistance = Infinity

    this.slideTargets.forEach((slide, index) => {
      const slideCenter = slide.offsetLeft + slide.offsetWidth / 2
      const distance = Math.abs(trackCenter - slideCenter)

      if (distance < closestDistance) {
        closestDistance = distance
        closestIndex = index
      }
    })

    this.setActive(closestIndex)
  }

  scrollToIndex(index, options = {}) {
    if (!this.hasTrackTarget || this.slideTargets.length === 0) return

    const boundedIndex = this.clampIndex(index)
    const slide = this.slideTargets[boundedIndex]
    if (!slide) return

    this.setActive(boundedIndex)
    this.trackTarget.scrollTo({
      left: slide.offsetLeft,
      behavior: options.behavior || (this.motionAllowed ? "smooth" : "auto")
    })
  }

  setActive(index) {
    if (!this.hasTrackTarget || this.slideTargets.length === 0) return

    const boundedIndex = this.clampIndex(index)
    this.activeIndex = boundedIndex
    this.syncAccent()

    this.slideTargets.forEach((slide, slideIndex) => {
      const active = slideIndex === boundedIndex
      slide.classList.toggle("is-active", active)
      slide.setAttribute("aria-current", active ? "true" : "false")
      slide.setAttribute("aria-hidden", active ? "false" : "true")
    })

    this.dotTargets.forEach((dot, dotIndex) => {
      const active = dotIndex === boundedIndex
      dot.classList.toggle("is-active", active)
      dot.setAttribute("aria-current", active ? "true" : "false")
    })
  }

  syncAccent() {
    const activeSlide = this.slideTargets[this.activeIndex]
    const accent = activeSlide?.style.getPropertyValue("--pv2-hero-media-accent")

    if (accent) this.element.style.setProperty("--pv2-hero-media-accent", accent.trim())
  }

  clampIndex(index) {
    return Math.min(Math.max(index, 0), this.slideTargets.length - 1)
  }

  get motionAllowed() {
    return !window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  get initialIndex() {
    if (this.slideTargets.length === 0) return 0

    return this.clampIndex(this.initialIndexValue || 0)
  }
}
