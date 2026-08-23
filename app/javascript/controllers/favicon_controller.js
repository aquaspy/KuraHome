import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    if (this.element.complete && this.element.naturalWidth > 0) this.show()
  }

  show() {
    this.element.closest(".mark")?.classList.add("has-icon")
  }

  hide() {
    this.element.remove()
  }
}
