import { Controller } from "@hotwired/stimulus"

// Turbo Frame 内の末尾に配置された sentinel がビューポートに入ったら
// 次ページのリンクを自動クリックして追加読み込みするシンプルな無限スクロール。
export default class extends Controller {
  static targets = ["sentinel", "link"]

  connect() {
    if (!("IntersectionObserver" in window)) return

    this.loading = false
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.loadMore()
        }
      })
    }, { root: null, threshold: 0.1 })

    this.observeSentinel()
  }

  disconnect() {
    this.observer?.disconnect()
  }

  reset() {
    this.loading = false
    this.observeSentinel()
  }

  loadMore() {
    if (this.loading) return
    this.loading = true

    if (this.hasLinkTarget) {
      this.linkTarget.click()
    }
  }

  observeSentinel() {
    if (!this.observer) return
    this.observer.disconnect()

    if (this.hasSentinelTarget && this.hasLinkTarget) {
      this.observer.observe(this.sentinelTarget)
    }
  }
}
