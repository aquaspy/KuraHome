import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "siteBox", "siteForm", "siteHeading", "siteMethod", "siteDelete",
    "profileBox", "profileForm", "profileHeading", "profileMethod", "profileDelete",
    "stackBox", "stackForm", "stackHeading", "stackMethod", "stackDelete"
  ]

  openSite(event) {
    const trigger = event.currentTarget
    const id = trigger.dataset.siteId
    const form = this.siteFormTarget
    form.action = id ? `/sites/${id}` : "/sites"
    if (this.hasSiteMethodTarget) this.siteMethodTarget.value = id ? "patch" : "post"
    form.querySelector("[name='site[profile_id]']").value = trigger.dataset.profileId || ""
    form.querySelector("[name='site[title]']").value = trigger.dataset.title || ""
    form.querySelector("[name='site[url]']").value = trigger.dataset.url || ""
    form.querySelector("[name='site[hint]']").value = trigger.dataset.hint || ""
    form.querySelector("[name='site[icon_url]']").value = trigger.dataset.iconUrl || ""
    if (this.hasSiteHeadingTarget) {
      this.siteHeadingTarget.textContent = trigger.dataset.heading || ""
    }
    if (this.hasSiteDeleteTarget) {
      this.siteDeleteTarget.hidden = !id
      const del = this.siteDeleteTarget.querySelector("form")
      if (del && id) del.action = `/sites/${id}`
    }
    const title = form.querySelector("[name='site[title]']")
    this.siteBoxTarget.showModal()
    title?.focus()
  }

  openProfile(event) {
    const trigger = event.currentTarget
    const id = trigger.dataset.profileId
    const form = this.profileFormTarget
    form.action = id ? `/profiles/${id}` : "/profiles"
    if (this.hasProfileMethodTarget) this.profileMethodTarget.value = id ? "patch" : "post"
    form.querySelector("[name='profile[name]']").value = trigger.dataset.name || ""
    if (this.hasProfileHeadingTarget) {
      this.profileHeadingTarget.textContent = trigger.dataset.heading || ""
    }
    if (this.hasProfileDeleteTarget) {
      const canDelete = trigger.dataset.destroyable === "true" && id
      this.profileDeleteTarget.hidden = !canDelete
      const del = this.profileDeleteTarget.querySelector("form")
      if (del && id) del.action = `/profiles/${id}`
    }
    const name = form.querySelector("[name='profile[name]']")
    this.profileBoxTarget.showModal()
    name?.focus()
  }

  closeSite() { this.siteBoxTarget.close() }
  closeProfile() { this.profileBoxTarget.close() }
  closeStack() { this.stackBoxTarget.close() }

  openStack(event) {
    const trigger = event.currentTarget
    const id = trigger.dataset.itemId
    const form = this.stackFormTarget
    form.action = id ? `/stack_items/${id}` : "/stack_items"
    if (this.hasStackMethodTarget) this.stackMethodTarget.value = id ? "patch" : "post"
    form.querySelector("[name='stack_item[profile_id]']").value = trigger.dataset.profileId || ""
    form.querySelector("[name='stack_item[category]']").value = trigger.dataset.category || ""
    form.querySelector("[name='stack_item[choice]']").value = trigger.dataset.choice || ""
    form.querySelector("[name='stack_item[origin]']").value = trigger.dataset.origin || ""
    form.querySelector("[name='stack_item[note]']").value = trigger.dataset.note || ""
    form.querySelector("[name='stack_item[url]']").value = trigger.dataset.url || ""
    form.querySelector("[name='stack_item[icon_url]']").value = trigger.dataset.iconUrl || ""
    if (this.hasStackHeadingTarget) {
      this.stackHeadingTarget.textContent = trigger.dataset.heading || ""
    }
    if (this.hasStackDeleteTarget) {
      this.stackDeleteTarget.hidden = !id
      const del = this.stackDeleteTarget.querySelector("form")
      if (del && id) del.action = `/stack_items/${id}`
    }
    const category = form.querySelector("[name='stack_item[category]']")
    this.stackBoxTarget.showModal()
    category?.focus()
  }

  backdrop(event) {
    if (event.target === this.siteBoxTarget) this.closeSite()
    if (event.target === this.profileBoxTarget) this.closeProfile()
    if (this.hasStackBoxTarget && event.target === this.stackBoxTarget) this.closeStack()
  }
}
