import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["success"];

  connect() {
    console.log("Formsuccess controller connected");

    if (this.hasSuccessTarget) {
      setTimeout(() => {
        this.removeNotification();
      }, 2000);
    }
  }

  disconnect() {
    console.log("Formsuccess controller disconnected");
  }

  removeNotification() {
    // Si la notification existe, la supprimer du DOM
    console.log("Inside removeNotif !!!!!!");
    if (this.hasSuccessTarget) {
      this.successTarget.remove();
    }
  }
}
