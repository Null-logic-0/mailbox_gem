import { Controller } from "@hotwired/stimulus"

// Keeps resultsTarget in sync with baseUrlValue+queryValue two ways: a
// periodic poll (new mail arriving), and live as the user types in the
// search input (debounced, so it's not one fetch per keystroke).
//
// Only resultsTarget's contents are ever replaced, never the controller's
// own element - the search input has to survive a refresh mid-keystroke.
//
// Progressive enhancement: the form is a real GET fallback if this never
// connects (JS disabled). #submit prevents that navigation when it can,
// since a full page reload defeats the point of "no reload" search.
export default class extends Controller {
  static targets = [ "results", "search" ]
  static values = {
    baseUrl: String,
    query: String,
    interval: { type: Number, default: 3000 },
    debounce: { type: Number, default: 300 },
  }

  connect() {
    this.requestId = 0
    this.timer = setInterval(() => this.refresh(), this.intervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
    clearTimeout(this.debounceTimer)
  }

  search(event) {
    this.queryValue = event.target.value

    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => this.refresh(), this.debounceValue)
  }

  submit(event) {
    event.preventDefault()
    clearTimeout(this.debounceTimer)
    this.refresh()
  }

  async refresh() {
    const url = this.queryValue
      ? `${this.baseUrlValue}?q=${encodeURIComponent(this.queryValue)}`
      : this.baseUrlValue

    // The debounced keystroke fetch and the periodic poll can race; a slow
    // response for an older query shouldn't ever overwrite a newer one.
    const requestId = ++this.requestId
    const response = await fetch(url, { headers: { Accept: "text/html" } })
    if (response.ok && requestId === this.requestId) {
      this.resultsTarget.innerHTML = await response.text()
    }
  }
}
