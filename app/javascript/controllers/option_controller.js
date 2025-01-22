import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ["list", "template"];

  connect() {
    console.log("OptionsController connected");
  }

  addOption(event) {
    event.preventDefault();

    // Clone the template and add it to the list
    const templateContent = this.templateTarget.content.cloneNode(true);
    this.listTarget.appendChild(templateContent);
  }
}