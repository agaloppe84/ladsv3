import { Controller } from "@hotwired/stimulus";
import TomSelect from "tom-select";

export default class extends Controller {
  connect() {
    console.log("TomSelect is ready !!!")
    this.element.style.display = "none";
    new TomSelect(this.element, {
      plugins: ["remove_button","dropdown_input"],
      placeholder: "Sélectionnez une ou plusieurs options",
      maxOptions: null
    });
  }
}
