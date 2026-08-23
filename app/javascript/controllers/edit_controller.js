import { Controller } from "@hotwired/stimulus"
import { t } from "i18n"

export default class extends Controller {
  static targets = [ "label" ]

  toggle(event) {
    event?.preventDefault()
    this.element.classList.toggle("is-editing")
    this.paint()
  }

  paint() {
    const on = this.element.classList.contains("is-editing")
    this.labelTargets.forEach((el) => {
      el.textContent = on ? t("done") : t("edit")
      el.closest("button")?.setAttribute("aria-pressed", String(on))
    })
  }
}
