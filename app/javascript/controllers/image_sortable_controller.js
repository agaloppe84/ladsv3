import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  static targets = ["position"];

  connect() {
    this.sortable = new Sortable(this.element, {
      animation: 150,
      draggable: "[data-image-sortable-item]",
      handle: ".image-sortable-handle",
      onEnd: () => this.updatePositions(),
    });

    this.updatePositions();
  }

  disconnect() {
    if (this.sortable) {
      this.sortable.destroy();
    }
  }

  updatePositions() {
    this.positionTargets.forEach((positionTarget, index) => {
      positionTarget.textContent = index + 1;
    });
  }
}
