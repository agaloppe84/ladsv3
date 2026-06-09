import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link", "section", "track"]

  connect() {
    this.activeAnchorId = null
    this.pendingActiveFrame = null
    this.hashChangeHandler = () => this.activateFromHash()
    this.popStateHandler = () => {
      if (!this.activateFromHash({ scroll: true })) this.queueActiveUpdate()
    }
    this.scrollHandler = () => this.queueActiveUpdate()
    this.resizeHandler = () => {
      this.refreshObserver()
      this.queueActiveUpdate()
    }

    window.addEventListener("hashchange", this.hashChangeHandler)
    window.addEventListener("popstate", this.popStateHandler)
    window.addEventListener("scroll", this.scrollHandler, { passive: true })
    window.addEventListener("resize", this.resizeHandler, { passive: true })

    if (!this.activateFromHash()) {
      this.setActive(this.anchorIdFromLink(this.linkTargets[0]), { scrollLink: false })
    }

    this.refreshObserver()
    this.queueActiveUpdate()
  }

  disconnect() {
    window.removeEventListener("hashchange", this.hashChangeHandler)
    window.removeEventListener("popstate", this.popStateHandler)
    window.removeEventListener("scroll", this.scrollHandler)
    window.removeEventListener("resize", this.resizeHandler)
    if (this.observer) this.observer.disconnect()
    if (this.pendingActiveFrame) cancelAnimationFrame(this.pendingActiveFrame)
  }

  activateFromClick(event) {
    const anchorId = this.anchorIdFromLink(event.currentTarget)
    if (!anchorId || !this.hasSection(anchorId)) return

    event.preventDefault()

    this.setActive(anchorId)
    this.scrollToSection(anchorId, { behavior: this.motionAllowed ? "smooth" : "auto" })
    this.updateHash(anchorId)
  }

  activateFromHash(options = {}) {
    const anchorId = window.location.hash.replace("#", "")
    if (!anchorId || !this.hasSection(anchorId)) return false

    this.setActive(anchorId)
    if (options.scroll) this.scrollToSection(anchorId, { behavior: "auto" })

    return true
  }

  refreshObserver() {
    if (this.observer) this.observer.disconnect()
    if (!("IntersectionObserver" in window)) return

    this.observer = new IntersectionObserver(() => {
      this.queueActiveUpdate()
    }, {
      rootMargin: this.observerRootMargin,
      threshold: [0, 0.01, 0.1, 0.25, 0.5, 0.75, 1]
    })

    this.sectionTargets.forEach((section) => this.observer.observe(section))
  }

  queueActiveUpdate() {
    if (this.pendingActiveFrame) return

    this.pendingActiveFrame = requestAnimationFrame(() => {
      this.pendingActiveFrame = null
      const anchorId = this.currentAnchorId()

      if (anchorId) this.setActive(anchorId)
    })
  }

  currentAnchorId() {
    if (!this.hasSectionTarget) return this.anchorIdFromLink(this.linkTargets[0])

    const activationY = this.activationY
    let currentAnchorId = this.sectionTargets[0]?.id

    this.sectionTargets.some((section) => {
      const rect = section.getBoundingClientRect()
      const anchorId = section.id

      if (!anchorId) return false

      if (rect.top <= activationY) currentAnchorId = anchorId

      return rect.top > activationY
    })

    if (this.isNearPageBottom) return this.sectionTargets[this.sectionTargets.length - 1]?.id || currentAnchorId

    return currentAnchorId
  }

  setActive(anchorId, options = {}) {
    if (!anchorId || this.activeAnchorId === anchorId) return

    this.activeAnchorId = anchorId

    this.linkTargets.forEach((link) => {
      const active = this.anchorIdFromLink(link) === anchorId
      link.classList.toggle("is-active", active)

      if (active) {
        link.setAttribute("aria-current", "location")
      } else {
        link.removeAttribute("aria-current")
      }

      if (active && options.scrollLink !== false) this.scrollActiveLink(link)
    })
  }

  hasSection(anchorId) {
    return Boolean(this.sectionFor(anchorId))
  }

  scrollToSection(anchorId, options = {}) {
    const section = this.sectionFor(anchorId)
    if (!section) return

    const behavior = options.behavior || "auto"
    const top = window.scrollY + section.getBoundingClientRect().top - this.scrollOffset

    window.scrollTo({
      top: Math.max(0, top),
      behavior
    })
  }

  sectionFor(anchorId) {
    return this.sectionTargets.find((target) => target.id === anchorId)
  }

  updateHash(anchorId) {
    const nextHash = `#${anchorId}`
    if (window.location.hash === nextHash) return

    window.history.pushState(null, "", nextHash)
  }

  scrollActiveLink(link) {
    if (!this.hasTrackTarget || this.trackTarget.scrollWidth <= this.trackTarget.clientWidth) return

    const left = link.offsetLeft + (link.offsetWidth / 2) - (this.trackTarget.clientWidth / 2)

    this.trackTarget.scrollTo({
      left: Math.max(0, left),
      behavior: this.motionAllowed ? "smooth" : "auto"
    })
  }

  anchorIdFromLink(link) {
    if (!link) return null

    return link.hash?.replace("#", "")
  }

  get observerRootMargin() {
    return "-50% 0px -49% 0px"
  }

  get activationY() {
    return Math.round(window.innerHeight * 0.5)
  }

  get isNearPageBottom() {
    const scrollBottom = window.scrollY + window.innerHeight
    const pageBottom = document.documentElement.scrollHeight

    return scrollBottom >= pageBottom - 4
  }

  get scrollOffset() {
    const nav = document.querySelector(".pv2-public-nav")
    const navHeight = nav ? nav.getBoundingClientRect().height : 68
    const railHeight = this.hasTrackTarget ? this.trackTarget.getBoundingClientRect().height : 56

    return Math.round(navHeight + railHeight + 18)
  }

  get motionAllowed() {
    return !window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
