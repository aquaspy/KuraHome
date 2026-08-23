import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }

  start(event) {
    if (!this.element.closest(".is-editing")) {
      event.preventDefault()
      return
    }
    this.dragging = event.currentTarget
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.id)
    event.currentTarget.classList.add("is-dragging")
  }

  over(event) {
    if (!this.dragging) return
    event.preventDefault()
    const row = event.currentTarget
    if (row === this.dragging || !row.dataset.id) return
    const rect = row.getBoundingClientRect()
    const vertical = row.tagName === "TR"
    const before = vertical
      ? event.clientY < rect.top + rect.height / 2
      : event.clientX < rect.left + rect.width / 2
    row.parentNode.insertBefore(this.dragging, before ? row : row.nextSibling)
  }

  drop(event) {
    event.preventDefault()
    this.finish()
  }

  end() {
    this.dragging?.classList.remove("is-dragging")
    this.dragging = null
  }

  finish() {
    if (!this.hasUrlValue) return
    const ids = [...this.element.querySelectorAll("[data-id]")].map((el) => el.dataset.id)
    const token = document.querySelector("meta[name='csrf-token']")?.content
    const body = new URLSearchParams()
    ids.forEach((id) => body.append("ids[]", id))
    fetch(this.urlValue, {
      method: "PATCH",
      headers: { "X-CSRF-Token": token, Accept: "application/json" },
      body
    }).catch(() => {})
  }
}
