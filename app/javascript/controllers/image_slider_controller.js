import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    images: Array  // La liste de vos URLs d'images
  }
  static targets = ["image"]

  connect() {
    this.index = 0
    this.startRotation()
  }

  startRotation() {
    // Change d'image toutes les 3000 ms (3 sec) – passez à 4000 pour 4 sec
    this.timer = setInterval(() => {
      this.index = (this.index + 1) % this.imagesValue.length
      this.imageTarget.src = this.imagesValue[this.index]
    }, 3000)
  }

  disconnect() {
    clearInterval(this.timer)
  }
}
