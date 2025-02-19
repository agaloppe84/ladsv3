import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["content"]

  removeOpacity() {
    setTimeout(() => {
      this.contentTarget.classList.remove("opacity-0");
    }, 100);
  }
}
