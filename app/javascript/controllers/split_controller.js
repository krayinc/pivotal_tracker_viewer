import { Controller } from "@hotwired/stimulus"

// Allows the stories list/detail layout to be resized with a draggable divider.
export default class extends Controller {
  static targets = ["paneLeft", "paneRight", "handle"]
  static values = {
    minLeft: Number,
    minRight: Number,
    storageKey: String
  }

  connect() {
    this.boundMove = this.move.bind(this)
    this.boundEnd = this.end.bind(this)
    this.minLeft = this.minLeftValue || 320
    this.minRight = this.minRightValue || 320
    this.storageKey = this.storageKeyValue || "stories-split-width"

    const saved = this.readSavedWidth()
    if (saved) {
      this.element.style.setProperty("--stories-left-width", saved)
    }
  }

  disconnect() {
    this.end()
  }

  start(event) {
    event.preventDefault()
    this.startDrag = true
    this.containerRect = this.element.getBoundingClientRect()
    this.dividerWidth = this.handleTarget.offsetWidth || 12

    document.addEventListener("pointermove", this.boundMove)
    document.addEventListener("pointerup", this.boundEnd)

    this.handleTarget.classList.add("is-active")
    this.element.classList.add("is-resizing")
  }

  move(event) {
    if (!this.startDrag) return

    const clientX = event.clientX
    if (clientX == null) return

    const offset = clientX - this.containerRect.left
    const max = this.containerRect.width - this.minRight - this.dividerWidth
    const clamped = Math.max(this.minLeft, Math.min(offset, max))

    this.element.style.setProperty("--stories-left-width", `${clamped}px`)
  }

  end(event) {
    if (!this.startDrag) return

    if (event && event.type === "pointerup") {
      this.move(event)
    }

    this.startDrag = false
    document.removeEventListener("pointermove", this.boundMove)
    document.removeEventListener("pointerup", this.boundEnd)

    const width = this.element.style.getPropertyValue("--stories-left-width")
    if (width) {
      this.saveWidth(width)
    }

    this.handleTarget.classList.remove("is-active")
    this.element.classList.remove("is-resizing")
  }

  saveWidth(value) {
    try {
      window.localStorage.setItem(this.storageKey, value)
    } catch (error) {
      // ignore storage errors (Safari private mode, etc.)
    }
  }

  readSavedWidth() {
    try {
      return window.localStorage.getItem(this.storageKey)
    } catch (error) {
      return null
    }
  }
}
