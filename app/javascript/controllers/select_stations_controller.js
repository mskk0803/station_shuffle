import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="select-stations"
export default class extends Controller {

  static targets = ["stations"]

  // 全部選択する
  selectAll() {

    console.log(this.stationsTargets)
    this.stationsTargets.forEach((station) => {
      station.checked = true
    })
    

  }

}
