import { Controller } from "@hotwired/stimulus"
import { t } from "i18n"

export default class extends Controller {
  static targets = ["greeting", "clock"]

  connect() {
    this.tick()
    this.timer = setInterval(() => this.tick(), 30_000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const now = new Date()
    const hour = now.getHours()
    const key = hour < 12 ? "morning" : hour < 18 ? "afternoon" : "evening"
    if (this.hasGreetingTarget) this.greetingTarget.textContent = t(key)

    if (this.hasClockTarget) {
      const locale = document.documentElement.lang || "en"
      this.clockTarget.dateTime = now.toISOString()
      const date = now.toLocaleDateString(locale, { weekday: "long", month: "long", day: "numeric" })
      const time = now.toLocaleTimeString(locale, { hour: "numeric", minute: "2-digit" })
      this.clockTarget.textContent = `${date} · ${time}`
    }
  }
}
