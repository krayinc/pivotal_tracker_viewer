import { Controller } from "@hotwired/stimulus"

// Searchable label picker that submits the filter form automatically.
export default class extends Controller {
  static targets = ["search", "list", "item"]
  static values = { delay: Number }

  connect() {
    this.submit = this.submit.bind(this)
    if (this.hasSearchTarget) {
      this.filter(this.searchTarget.value)
    }
  }

  search(event) {
    this.filter(event.target.value)
  }

  toggle() {
    this.submit()
  }

  preventSubmit(event) {
    if (event.key === "Enter") {
      event.preventDefault()
    }
  }

  submit() {
    clearTimeout(this.timeout)

    const delay = this.hasDelayValue ? this.delayValue : 0
    this.timeout = setTimeout(() => {
      const form = this.element.closest("form")
      if (form) form.requestSubmit()
    }, delay)
  }

  filter(value) {
    const term = (value || "").trim().toLowerCase()

    this.itemTargets.forEach(element => {
      const name = (element.dataset.name || element.textContent || "").toLowerCase()
      const shouldHide = term.length > 0 && !name.includes(term)
      element.classList.toggle("is-hidden", shouldHide)
    })
  }
}
