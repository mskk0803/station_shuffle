import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]
  static values = { url: String }

  search() {
    // 空白を除いたクエリを取得
    const query = this.inputTarget.value.trim()
    if (query.length < 2) {
      this.resultsTarget.innerHTML = ""
      return
    }
    console.log(this.urlValue)

    fetch(`${this.urlValue}?search=${encodeURIComponent(query)}`)
      .then(response => response.json())
      .then(data => this.showResults(data))
      .catch(error => console.error("オートコンプリート失敗:", error))
  }

  showResults(data) {
    this.resultsTarget.innerHTML = ""

    if (data.length === 0) {
      this.resultsTarget.innerHTML = "<li class='p-2 text-gray-500'>該当なし</li>"
      return
    }

    data.forEach(user => {
      const li = document.createElement("li")
      li.textContent = user.name
      li.className = "p-2 hover:bg-gray-100 cursor-pointer"
      li.addEventListener("click", () => this.selectUser(user.name))
      this.resultsTarget.appendChild(li)
    })
  }

  selectUser(name) {
    this.inputTarget.value = name
    this.resultsTarget.innerHTML = ""
  }
}