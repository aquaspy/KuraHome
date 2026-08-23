import { Controller } from "@hotwired/stimulus"
import { t } from "i18n"

const ENGINES = [
  { id: "duckduckgo", action: "https://duckduckgo.com/" },
  { id: "startpage", action: "https://www.startpage.com/sp/search", query: "query" },
  { id: "kagi", action: "https://kagi.com/search" },
  { id: "google", action: "https://www.google.com/search" },
  { id: "brave", action: "https://search.brave.com/search" }
]

export default class extends Controller {
  static targets = ["engine", "query"]

  connect() {
    this.apply(localStorage.getItem("kura.search") || "duckduckgo")
    this.onKey = (event) => {
      if (event.key !== "/" || event.metaKey || event.ctrlKey || event.altKey) return
      if (this.typing(event)) return
      event.preventDefault()
      if (this.hasQueryTarget) this.queryTarget.focus()
    }
    window.addEventListener("keydown", this.onKey)
  }

  disconnect() {
    window.removeEventListener("keydown", this.onKey)
  }

  cycle(event) {
    event.preventDefault()
    const index = ENGINES.findIndex((engine) => engine.id === this.current)
    this.apply(ENGINES[(index + 1) % ENGINES.length].id)
  }

  apply(id) {
    const engine = ENGINES.find((item) => item.id === id) || ENGINES[0]
    this.current = engine.id
    this.element.action = engine.action
    if (this.hasQueryTarget) this.queryTarget.setAttribute("name", engine.query || "q")
    localStorage.setItem("kura.search", engine.id)
    if (this.hasEngineTarget) this.engineTarget.textContent = t(`search_${engine.id === "duckduckgo" ? "ddg" : engine.id}`)
  }

  typing(event) {
    const tag = event.target.tagName
    return tag === "INPUT" || tag === "TEXTAREA" || event.target.isContentEditable
  }
}
