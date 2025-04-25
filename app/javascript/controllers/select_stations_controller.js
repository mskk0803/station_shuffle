import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="select-stations"
export default class extends Controller {

  static targets = ["stations"]

  // 全部選択する
  selectAll() {
    this.stationsTargets.forEach((station) => {
      station.checked = true
    })
  
  }

}
