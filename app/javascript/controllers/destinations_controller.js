import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="destinations"
export default class extends Controller {

  static targets = ["list"];
  
  // button押下時に発火するイベント
  getGeoLocation(){
    navigator.geolocation.getCurrentPosition(
      this.success.bind(this),
      this.error.bind(this)
    )
  }

  success(position){
    const lat = position.coords.latitude
    const lon = position.coords.longitude
    // Railsにデータを送信
    this.sendLocation(lat, lon)
  }

  error(err){
    console.log("error:" + err.message)
  }

  // データ送信メソッド
  sendLocation(lat, lon){
    // Railsのcontrollerに送信
    fetch('/destinations/get_location', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({lat: lat, lon: lon})
    })
    .then(response => response.json())
    .then(data => {
      console.log(data)
      if (this.hasListTarget) { 
        let stationElement = document.createElement("p");
        stationElement.textContent = `(緯度: ${data.latitude}, 経度: ${data.longitude})`;
        this.listTarget.appendChild(stationElement);
      } else {
        console.error("listTarget が見つかりません");
      }
    })
    .catch((error) => {
      console.error('Error:', error);
    });

  }
}
