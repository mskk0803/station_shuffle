import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="destinations"
export default class extends Controller {

  static targets = ["latitude", "longitude"]

  // 自動で位置情報を取得する
  connect() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.latitudeTarget.value = position.coords.latitude
          this.longitudeTarget.value = position.coords.longitude
        },
        (error) => {
          console.error("位置情報の取得に失敗しました:", error)
        }
      )
    } else {
      console.error("このブラウザでは位置情報がサポートされていません。")
    }
  }
}
