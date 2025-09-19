import { Controller } from "@hotwired/stimulus"

// Searchable label picker that submits the filter form automatically.
export default class extends Controller {
  static targets = ["search", "list", "item"]
  static values = { delay: Number }

  connect() {
    this.submit = this.submit.bind(this)
  }

  search(event) {
    const term = event.target.value.trim().toLowerCase()

    this.itemTargets.forEach(element => {
      const name = element.dataset.name || ""
      element.hidden = term && !name.includes(term)
    })
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
}
