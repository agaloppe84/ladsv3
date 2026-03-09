import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return

          entry.target.classList.remove("opacity-0", "translate-y-4")
          entry.target.classList.add("opacity-100", "translate-y-0")
          this.observer.unobserve(entry.target)
        })
      },
      { threshold: 0.12 }
    )

    this.itemTargets.forEach((item) => this.observer.observe(item))
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }
}
