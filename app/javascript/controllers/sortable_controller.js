import { Controller } from "@hotwired/stimulus";
import Sortable from "sortablejs";

export default class extends Controller {
  connect() {
    console.log("Sortable active")
    this.sortable = new Sortable(this.element, {
      handle: ".drag-handle", // Classe pour identifier les éléments "draggable"
      animation: 150, // Animation fluide
      onEnd: (event) => {
        this.updateOrder(event);
      },
    });
  }

  updateOrder(event) {
    // Extraire les éléments triés
    const sortedItems = this.sortable.el.children;

    // Mettre à jour chaque champ "order" pour chaque élément trié
    Array.from(sortedItems).forEach((item, index) => {
      // Trouver le champ de l'option correspondante
      const orderInput = item.querySelector("input[name*='[order]']");
      if (orderInput) {
        orderInput.value = parseInt(index) + 1; // Assigner le nouvel ordre
      }
    });

    console.log("Ordre mis à jour pour chaque champ.");
  }
}
