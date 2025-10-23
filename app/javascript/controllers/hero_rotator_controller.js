import { Controller } from "@hotwired/stimulus"

// data-controller="hero-rotator"
// data-hero-rotator-interval-value="5000" (ou 10000)
// data-hero-rotator-pause-on-hover-value="true"
export default class extends Controller {
  static targets = ["slide"]
  static values = {
    interval: { type: Number, default: 7000 },
    pauseOnHover: { type: Boolean, default: true }
  }

  connect() {
    this.index = 0
    if (!this.hasSlideTarget || this.slideTargets.length === 0) return

    // initialise : montre la première, cache les autres
    this.slideTargets.forEach((el, i) => this._setVisible(el, i === 0))

    if (this.slideTargets.length > 1) this.start()

    if (this.pauseOnHoverValue) {
      this._onEnter = () => this.stop()
      this._onLeave = () => this.start()
      this.element.addEventListener("mouseenter", this._onEnter)
      this.element.addEventListener("mouseleave", this._onLeave)
      this._onVis = () => (document.hidden ? this.stop() : this.start())
      document.addEventListener("visibilitychange", this._onVis)
    }
  }

  disconnect() {
    this.stop()
    if (this.pauseOnHoverValue) {
      this.element.removeEventListener("mouseenter", this._onEnter)
      this.element.removeEventListener("mouseleave", this._onLeave)
      document.removeEventListener("visibilitychange", this._onVis)
    }
  }

  start() {
    if (this._timer) return
    this._timer = setInterval(() => this.next(), this.intervalValue)
  }

  stop() {
    if (this._timer) clearInterval(this._timer)
    this._timer = null
  }

  next() {
    const prev = this.index
    const next = (this.index + 1) % this.slideTargets.length
    if (prev === next) return
    this._setVisible(this.slideTargets[prev], false)
    this._setVisible(this.slideTargets[next], true)
    this.index = next
  }

  prev() {
    const prev = this.index
    const next = (this.index - 1 + this.slideTargets.length) % this.slideTargets.length
    this._setVisible(this.slideTargets[prev], false)
    this._setVisible(this.slideTargets[next], true)
    this.index = next
  }

  _setVisible(el, visible) {
    // gestion visibilité + accessibilité + fondu
    el.classList.toggle("opacity-0", !visible)
    el.classList.toggle("pointer-events-none", !visible)
    el.setAttribute("aria-hidden", visible ? "false" : "true")
  }
}
