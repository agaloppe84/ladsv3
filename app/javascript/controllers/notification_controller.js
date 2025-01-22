import { Controller } from '@hotwired/stimulus'

export default class extends Controller {

  connect() {
    setTimeout(() => {
      this.close()
    }, 4000)
  }

  close() {
    this.element.classList.add('translate-x-full')
    this.element.classList.add('opacity-0')
    this.element.classList.add('hidden')
  }
}