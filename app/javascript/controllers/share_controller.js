import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "payload" ]
  static values = { title: String, profile: String, footer: String }

  async download(event) {
    event.preventDefault()
    const rows = JSON.parse(this.payloadTarget.textContent)
    if (!rows.length) return

    await loadIcons(rows)
    const canvas = drawCard(rows, {
      title: this.titleValue,
      profile: this.profileValue,
      footer: this.footerValue
    })
    const link = document.createElement("a")
    const slug = (this.profileValue || "stack").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "")
    link.download = `kura-stack-${slug || "home"}.png`
    link.href = canvas.toDataURL("image/png")
    link.click()
  }
}

function loadIcons(rows) {
  return Promise.all(rows.map((row) => new Promise((resolve) => {
    if (!row.icon) return resolve()
    const img = new Image()
    img.onload = () => { row.image = img; resolve() }
    img.onerror = () => resolve()
    img.src = row.icon
  })))
}

function drawCard(rows, copy) {
  const dpr = 2
  const width = 1080
  const pad = 72
  const rowH = 78
  const height = pad + 120 + rows.length * rowH + 80
  const canvas = document.createElement("canvas")
  canvas.width = width * dpr
  canvas.height = height * dpr
  const ctx = canvas.getContext("2d")
  ctx.scale(dpr, dpr)

  ctx.fillStyle = "#f7f3eb"
  ctx.fillRect(0, 0, width, height)
  const glow = ctx.createRadialGradient(width / 2, 0, 40, width / 2, 0, 520)
  glow.addColorStop(0, "rgba(232, 212, 184, 0.85)")
  glow.addColorStop(1, "rgba(247, 243, 235, 0)")
  ctx.fillStyle = glow
  ctx.fillRect(0, 0, width, 360)

  ctx.fillStyle = "#1c1916"
  ctx.font = "500 54px ui-serif, Palatino, Georgia, serif"
  ctx.fillText(copy.title, pad, pad + 48)
  ctx.fillStyle = "#8a8378"
  ctx.font = "400 22px ui-sans-serif, system-ui, sans-serif"
  ctx.fillText(copy.profile, pad, pad + 82)

  let y = pad + 130
  rows.forEach((row) => {
    round(ctx, pad, y, 36, 36, 10)
    if (row.image) {
      ctx.save()
      ctx.clip()
      ctx.fillStyle = "#fffdf8"
      ctx.fill()
      ctx.drawImage(row.image, pad + 6, y + 6, 24, 24)
      ctx.restore()
    } else {
      ctx.fillStyle = row.color || "#b55220"
      ctx.fill()
      ctx.fillStyle = "#fff8f2"
      ctx.font = "500 18px ui-serif, Palatino, Georgia, serif"
      ctx.textAlign = "center"
      ctx.fillText(row.letter || "?", pad + 18, y + 24)
      ctx.textAlign = "left"
    }

    ctx.fillStyle = "#8a8378"
    ctx.font = "500 13px ui-sans-serif, system-ui, sans-serif"
    ctx.fillText((row.category || "").toUpperCase(), pad + 56, y + 14)
    ctx.fillStyle = "#1c1916"
    ctx.font = "550 22px ui-sans-serif, system-ui, sans-serif"
    ctx.fillText(row.choice || "", pad + 56, y + 38)
    ctx.fillStyle = "#8a8378"
    ctx.font = "400 16px ui-sans-serif, system-ui, sans-serif"
    const meta = [ row.origin, row.note ].filter(Boolean).join("  ·  ")
    ctx.fillText(meta, pad + 56, y + 60)
    y += rowH
  })

  ctx.fillStyle = "#b55220"
  ctx.font = "500 16px ui-serif, Palatino, Georgia, serif"
  ctx.fillText(copy.footer || "KuraHome", pad, height - 36)
  return canvas
}

function round(ctx, x, y, w, h, r) {
  ctx.beginPath()
  ctx.moveTo(x + r, y)
  ctx.arcTo(x + w, y, x + w, y + h, r)
  ctx.arcTo(x + w, y + h, x, y + h, r)
  ctx.arcTo(x, y + h, x, y, r)
  ctx.arcTo(x, y, x + w, y, r)
  ctx.closePath()
}
