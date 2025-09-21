import { Controller } from "@hotwired/stimulus"

// Handles interactions in the story list cards (open detail, quick filters)
export default class extends Controller {
  static values = { url: String }

  open(event) {
    if (this.shouldIgnore(event)) return
    this.visitDetail()
  }

  openWithKey(event) {
    if (this.shouldIgnore(event)) return
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.visitDetail()
    }
  }

  applyLabel(event) {
    event.preventDefault()
    event.stopPropagation()
    const value = event.params.label
    if (!value) return

    const form = this.filterForm
    if (!form) return

    const inputs = form.querySelectorAll('input[name="filter[labels][]"]')
    inputs.forEach(input => {
      input.checked = input.value === value
    })

    form.requestSubmit()
  }

  applyOwner(event) {
    event.preventDefault()
    event.stopPropagation()
    const value = event.params.owner
    if (!value) return

    const form = this.filterForm
    if (!form) return

    const select = form.querySelector('select[name="filter[owners][]"]')
    if (!select) return

    Array.from(select.options).forEach(option => {
      option.selected = option.value == value
    })

    form.requestSubmit()
  }

  shouldIgnore(event) {
    const target = event.target
    return !this.hasUrlValue || !target || target.closest("a, button, input, textarea, select, label")
  }

  visitDetail() {
    if (!this.hasUrlValue) return

    const turbo = window.Turbo
    if (turbo) {
      turbo.visit(this.urlValue, { frame: "story_detail" })
    } else {
      window.location.href = this.urlValue
    }
  }

  get filterForm() {
    if (this._filterForm) return this._filterForm
    this._filterForm = this.element.closest(".app-page")?.querySelector("form.filter-card")
    return this._filterForm
  }

}
