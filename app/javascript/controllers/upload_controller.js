import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";

export default class extends Controller {
  static targets = ["input", "preview"];

  connect() {
    console.log("Upload controller connected");
  }

  triggerFileInput() {
    this.inputTarget.click(); // Simule un clic sur le champ caché
  }

  uploadFile(event) {
    const files = event.target.files;
    const inputElement = event.target;

    if (files.length > 0) {
      // Afficher la prévisualisation pour chaque fichier
      this.createPreview(files);

      // Créer un upload direct pour chaque fichier
      Array.from(files).forEach((file) => {
        const upload = new DirectUpload(file, '/rails/active_storage/direct_uploads', this);

        // Lier la méthode onSuccess au bon contexte avec bind
        const onSuccess = this.onSuccess.bind(this);

        // Démarrer l'upload pour chaque fichier
        upload.create((error, blob) => {
          if (error) {
            console.error("Erreur lors de l'upload", error);
          } else {
            // Appeler la méthode onSuccess avec l'ID signé du blob
            onSuccess(blob.signed_id);
            // Vider le champ de fichier après l'upload réussi
            inputElement.value = "";
          }
        });
      });
    }
  }

  // La méthode onSuccess qui traite l'ID signé après l'upload réussi
  onSuccess(signedId) {
    console.log("Upload réussi, ID signé :", signedId);
    // Exemple d'action à effectuer après l'upload réussi
    // Par exemple, ajouter un champ caché avec l'ID signé dans le formulaire
    const hiddenField = document.createElement("input");
    hiddenField.setAttribute("type", "hidden");
    hiddenField.setAttribute("value", signedId);
    hiddenField.name = "product[images][]"; // Assure-toi que ce nom correspond au nom de ton champ de formulaire
    this.element.appendChild(hiddenField);

    // Tu peux aussi ajouter une autre logique ici, comme afficher un message de succès ou mettre à jour l'interface.
  }

  // Créer une prévisualisation immédiate de l'image sélectionnée
  createPreview(files) {
    Array.from(files).forEach((file) => {
      const fileContainer = document.createElement("div");
      fileContainer.style.marginBottom = "20px";

      const fileUrl = URL.createObjectURL(file);
      const imageElement = document.createElement("img");
      imageElement.src = fileUrl;
      imageElement.alt = file.name;
      imageElement.style.maxWidth = "200px";
      imageElement.style.margin = "10px 0";
      imageElement.classList.add("rounded");

      const fileNameElement = document.createElement("div");
      fileNameElement.textContent = `${file.name}`;
      fileNameElement.classList.add("text-xs", "font-medium", "text-gray-700");

      const fileSizeElement = document.createElement("div");
      fileSizeElement.textContent = `${this.formatSize(file.size)}`;
      fileSizeElement.classList.add("text-[9px]", "font-bold", "text-indigo-700");

      fileContainer.appendChild(imageElement);
      fileContainer.appendChild(fileNameElement);
      fileContainer.appendChild(fileSizeElement);

      this.previewTarget.appendChild(fileContainer);
    });
  }

  // Formater la taille du fichier (en Ko / Mo)
  formatSize(size) {
    if (size < 1024) {
      return `${size} B`;
    } else if (size < 1024 * 1024) {
      return `${(size / 1024).toFixed(2)} KB`;
    } else {
      return `${(size / (1024 * 1024)).toFixed(2)} MB`;
    }
  }
}
