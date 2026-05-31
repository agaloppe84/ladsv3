import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link", "section"]

  connect() {
    this.visibleSections = new Map()
    this.hashChangeHandler = () => this.activateFromHash()
    window.addEventListener("hashchange", this.hashChangeHandler)

    if (!this.activateFromHash()) {
      this.setActive(this.anchorIdFromLink(this.linkTargets[0]))
    }

    this.observeSections()
  }

  disconnect() {
    window.removeEventListener("hashchange", this.hashChangeHandler)
    if (this.observer) this.observer.disconnect()
  }

  activateFromClick(event) {
    const anchorId = this.anchorIdFromLink(event.currentTarget)
    if (!anchorId || !this.hasSection(anchorId)) return

    event.preventDefault()

    this.setActive(anchorId)
    this.scrollToSection(anchorId, { behavior: this.motionAllowed ? "smooth" : "auto" })
    this.updateHash(anchorId)
  }

  activateFromHash() {
    const anchorId = window.location.hash.replace("#", "")
    if (!anchorId || !this.hasSection(anchorId)) return false

    this.setActive(anchorId)
    return true
  }

  observeSections() {
    if (!("IntersectionObserver" in window)) return

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        const anchorId = entry.target.id
        if (!anchorId) return

        if (entry.isIntersecting) {
          this.visibleSections.set(anchorId, entry)
        } else {
          this.visibleSections.delete(anchorId)
        }
      })

      const anchorId = this.closestVisibleAnchorId()
      if (anchorId) this.setActive(anchorId)
    }, {
      rootMargin: "-26% 0px -52% 0px",
      threshold: [0, 0.1, 0.25, 0.5, 0.75]
    })

    this.sectionTargets.forEach((section) => this.observer.observe(section))
  }

  closestVisibleAnchorId() {
    let candidate = null

    this.visibleSections.forEach((entry, anchorId) => {
      const distance = Math.abs(entry.boundingClientRect.top)
      const score = entry.intersectionRatio

      if (!candidate || score > candidate.score || (score === candidate.score && distance < candidate.distance)) {
        candidate = { anchorId, score, distance }
      }
    })

    return candidate?.anchorId
  }

  setActive(anchorId) {
    this.linkTargets.forEach((link) => {
      const active = this.anchorIdFromLink(link) === anchorId
      link.classList.toggle("is-active", active)

      if (active) {
        link.setAttribute("aria-current", "location")
      } else {
        link.removeAttribute("aria-current")
      }
    })
  }

  hasSection(anchorId) {
    return Boolean(this.sectionFor(anchorId))
  }

  scrollToSection(anchorId, options = {}) {
    const section = this.sectionFor(anchorId)
    if (!section) return

    const behavior = options.behavior || "auto"

    section.scrollIntoView({ block: "start", behavior })
  }

  sectionFor(anchorId) {
    return this.sectionTargets.find((target) => target.id === anchorId)
  }

  updateHash(anchorId) {
    const nextHash = `#${anchorId}`
    if (window.location.hash === nextHash) return

    window.history.pushState(null, "", nextHash)
  }

  anchorIdFromLink(link) {
    if (!link) return null

    return link.hash?.replace("#", "")
  }

  get motionAllowed() {
    return !window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
