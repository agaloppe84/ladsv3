import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["hiddenField"];
  static values = {
    signedId: String, // Valeur signée pour identifier l'image
  };

  // Méthode pour supprimer l'image et son champ caché
  remove() {
    // Supprimer le champ caché associé
    if (this.hasHiddenFieldTarget) {
      this.hiddenFieldTarget.remove();
    }

    // Supprimer le conteneur complet de l'image
    this.element.remove();
  }
}
