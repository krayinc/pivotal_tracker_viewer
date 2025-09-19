import { Controller } from "@hotwired/stimulus"

// Handles label token selection and auto submits the enclosing form after a short delay.
export default class extends Controller {
  static values = { delay: Number }

  connect() {
    this.submit = this.submit.bind(this)
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
