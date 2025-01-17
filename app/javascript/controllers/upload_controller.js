import { Controller } from "@hotwired/stimulus";
import { DirectUpload } from "@rails/activestorage";


export default class extends Controller {
  static targets = ["input", "progress", "preview"];

  connect() {
    console.log("Upload controller connected")
    console.log(this.inputTarget)
    console.log(this.progressTarget)
  }

  uploadFile() {
    Array.from(this.inputTarget.files).forEach((file) => {
      const newupload = this.createDirectUpload(file, this);
    });
  }

  createDirectUpload(file, context) {
    const upload = new DirectUpload(
      file,
      context.inputTarget.dataset.directUploadUrl,
      context,
      { directUploadWillStoreFileWithXHR: this.directUploadWillStoreFileWithXHR.bind(this) }
    );
    upload.create((error, blob) => {
      if (error) {
        console.log(error);
      } else {
        context.createHiddenBlobInput(blob);
        context.createPreview(blob);
      }
    });
  }


  // add blob id to be submitted with the form
  createHiddenBlobInput(blob) {
    const hiddenField = document.createElement("input");
    hiddenField.setAttribute("type", "hidden");
    hiddenField.setAttribute("value", blob.signed_id);
    hiddenField.name = this.inputTarget.name;
    this.element.appendChild(hiddenField);
  }



  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress", (event) => {
      this.progressUpdate(event);
    });
  }

  progressUpdate(event) {
    const progress = (event.loaded / event.total) * 100;
    this.progressTarget.innerHTML = `${progress} %`;
    if (progress == 100) {
      this.progressTarget.innerHTML = '';
    }
    console.log(progress);
  }

  // createPreview(blob) {
  //   const image = document.createElement("div");
  //   image.classList.add("p-4");
  //   image.classList.add("rounded");
  //   image.classList.add("border");
  //   image.classList.add("text-xs");
  //   image.classList.add("font-medium");
  //   image.innerHTML = `${blob.filename} - ${(blob.byte_size / 1000000).toFixed(2)} MB`;
  //   this.previewTarget.appendChild(image);
  // }

  createPreview(blob) {
    // Supprime les previews existants
    this.previewTarget.innerHTML = "";

    const fileUrl = URL.createObjectURL(this.inputTarget.files[0]);
    const imageElement = document.createElement("img");
    imageElement.src = fileUrl;
    imageElement.alt = blob.filename;
    imageElement.style.maxWidth = "200px";
    imageElement.style.margin = "10px 0";

    this.previewTarget.appendChild(imageElement);
  }


}