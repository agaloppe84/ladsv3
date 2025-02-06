// app/javascript/controllers/modal_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "image"]

  open(event) {
    event.preventDefault()
    // Récupère l'URL de l'image depuis le data attribute du bouton cliqué
    const url = event.currentTarget.dataset.modalUrlValue
    if (url) {
      this.imageTarget.src = url
    }
    // Affiche la modal en retirant la classe "hidden"
    this.containerTarget.classList.remove("hidden")
  }

  close(event) {
    event.preventDefault()
    // Cache la modal en réajoutant la classe "hidden"
    this.containerTarget.classList.add("hidden")
  }
}
