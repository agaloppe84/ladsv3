import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["panel"];

  connect() {
    console.log("Panel controller connected");
  }

  open() {
    console.log(this.panelTarget);
    this.panelTarget.classList.remove("hidden");
  }

  close() {
    this.panelTarget.classList.add("hidden");
  }
}
