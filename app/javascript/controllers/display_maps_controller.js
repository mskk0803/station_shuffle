import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="display-maps"
export default class extends Controller {
  static targets = ["map", "latitude", "longitude", "name"]
;
  connect() {
    const latitude = parseFloat(this.latitudeTarget.value)
    const longitude = parseFloat(this.longitudeTarget.value)
    const name = this.nameTarget.value

    // Google Maps APIが読み込まれていることを確認
    if (typeof google === "undefined") {
      console.error("Google Maps APIが読み込まれていません。")
      return
    }

    const position = { lat: latitude, lng: longitude }

    this.map = new google.maps.Map(this.mapTarget, {
      zoom: 15,
      center: position,
    })

    new google.maps.Marker({
      position: position,
      map: this.map,
      title: name,
    })
  }
}

