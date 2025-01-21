import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];

  initialize() {
    this.index = 0;
  }

  next(event) {
    event.preventDefault(); // Empêche le comportement par défaut du lien
    this.index = (this.index + 1) % this.totalItems;
    this.updateCarousel();
  }

  previous(event) {
    event.preventDefault(); // Empêche le comportement par défaut du lien
    this.index = (this.index - 1 + this.totalItems) % this.totalItems;
    this.updateCarousel();
  }

  updateCarousel() {
    const offset = this.index * -100;
    this.containerTarget.style.transform = `translateX(${offset}%)`;
  }


  get totalItems() {
    return this.containerTarget.children.length;
  }
}
