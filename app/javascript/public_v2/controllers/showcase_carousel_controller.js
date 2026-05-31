import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["track", "slide", "dot", "modal", "modalPanel", "modalImage", "modalCaption"]
  static values = { initialIndex: Number }

  connect() {
    this.activeIndex = 0
    this.syncFrame = null
    this.modalTimeout = null
    this.resizeHandler = () => this.queueSync()

    window.addEventListener("resize", this.resizeHandler)
    this.syncFrame = requestAnimationFrame(() => {
      this.syncFrame = null
      this.syncEdges()
      this.scrollToIndex(this.initialIndex, { behavior: "auto" })
      this.sync()
    })
  }

  disconnect() {
    window.removeEventListener("resize", this.resizeHandler)
    if (this.syncFrame) cancelAnimationFrame(this.syncFrame)
    if (this.modalTimeout) clearTimeout(this.modalTimeout)
    document.body.classList.remove("overflow-hidden")
  }

  queueSync() {
    if (this.syncFrame) cancelAnimationFrame(this.syncFrame)

    this.syncFrame = requestAnimationFrame(() => {
      this.syncFrame = null
      this.syncEdges()
      this.sync()
    })
  }

  scrollTo(event) {
    event.preventDefault()
    this.scrollToIndex(Number(event.params.index))
  }

  previous(event) {
    if (event) event.preventDefault()
    this.scrollToIndex(Math.max(this.activeIndex - 1, 0))
  }

  next(event) {
    if (event) event.preventDefault()
    this.scrollToIndex(Math.min(this.activeIndex + 1, this.slideTargets.length - 1))
  }

  openModal(event) {
    event.preventDefault()

    if (!this.hasModalTarget || !this.hasModalImageTarget) return

    this.modalImageTarget.src = event.params.src || ""
    this.modalImageTarget.alt = event.params.alt || ""

    if (this.hasModalCaptionTarget) {
      this.modalCaptionTarget.textContent = event.params.caption || ""
      this.modalCaptionTarget.hidden = !event.params.caption
    }

    if (this.modalTimeout) clearTimeout(this.modalTimeout)

    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")

    requestAnimationFrame(() => {
      this.modalTarget.classList.remove("opacity-0")
      this.modalTarget.classList.add("opacity-100")
      this.modalPanelTarget.classList.remove("opacity-0", "scale-95", "translate-y-2")
      this.modalPanelTarget.classList.add("opacity-100", "scale-100", "translate-y-0")
    })
  }

  closeModal(event) {
    if (event) event.preventDefault()
    if (!this.hasModalTarget) return

    this.modalTarget.classList.remove("opacity-100")
    this.modalTarget.classList.add("opacity-0")
    this.modalPanelTarget.classList.remove("opacity-100", "scale-100", "translate-y-0")
    this.modalPanelTarget.classList.add("opacity-0", "scale-95", "translate-y-2")

    this.modalTimeout = setTimeout(() => {
      this.modalTarget.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
      if (this.hasModalImageTarget) this.modalImageTarget.src = ""
    }, this.motionAllowed ? 220 : 0)
  }

  backdropClose(event) {
    if (event.target !== this.modalTarget) return
    this.closeModal(event)
  }

  sync() {
    if (!this.hasTrackTarget || this.slideTargets.length === 0) return

    const trackRect = this.trackTarget.getBoundingClientRect()
    const trackCenter = trackRect.left + trackRect.width / 2
    let closestIndex = 0
    let closestDistance = Infinity

    this.slideTargets.forEach((slide, index) => {
      const slideRect = slide.getBoundingClientRect()
      const slideCenter = slideRect.left + slideRect.width / 2
      const distance = Math.abs(trackCenter - slideCenter)

      if (distance < closestDistance) {
        closestDistance = distance
        closestIndex = index
      }
    })

    this.setActive(closestIndex)
  }

  syncEdges() {
    if (!this.hasTrackTarget || this.slideTargets.length === 0) return
    if (!this.element.classList.contains("pv2-ui-showcase-carousel--content")) return

    const trackWidth = this.trackTarget.clientWidth
    const firstWidth = this.slideTargets[0].getBoundingClientRect().width
    const lastWidth = this.slideTargets[this.slideTargets.length - 1].getBoundingClientRect().width
    const minimumEdge = 12

    this.trackTarget.style.setProperty("--pv2-showcase-start-edge", `${Math.max(minimumEdge, (trackWidth - firstWidth) / 2)}px`)
    this.trackTarget.style.setProperty("--pv2-showcase-end-edge", `${Math.max(minimumEdge, (trackWidth - lastWidth) / 2)}px`)
  }

  scrollToIndex(index, options = {}) {
    const slide = this.slideTargets[index]
    if (!slide || !this.hasTrackTarget) return

    const trackRect = this.trackTarget.getBoundingClientRect()
    const slideRect = slide.getBoundingClientRect()
    const targetLeft = this.trackTarget.scrollLeft +
      slideRect.left -
      trackRect.left -
      ((trackRect.width - slideRect.width) / 2)
    const maxLeft = Math.max(this.trackTarget.scrollWidth - this.trackTarget.clientWidth, 0)

    this.trackTarget.scrollTo({
      left: Math.min(Math.max(targetLeft, 0), maxLeft),
      behavior: options.behavior || (this.motionAllowed ? "smooth" : "auto")
    })

    this.setActive(index)
  }

  setActive(index) {
    this.activeIndex = index

    this.slideTargets.forEach((slide, slideIndex) => {
      const active = slideIndex === index
      slide.classList.toggle("is-active", active)
      slide.setAttribute("aria-current", active ? "true" : "false")
    })

    this.dotTargets.forEach((dot, dotIndex) => {
      const active = dotIndex === index
      dot.classList.toggle("is-active", active)
      dot.setAttribute("aria-current", active ? "true" : "false")
    })
  }

  get motionAllowed() {
    return !window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  get initialIndex() {
    if (this.slideTargets.length === 0) return 0

    return Math.min(Math.max(this.initialIndexValue || 0, 0), this.slideTargets.length - 1)
  }
}
