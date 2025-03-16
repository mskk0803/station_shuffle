import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="destinations"
export default class extends Controller {

  // 入力フォームと表示させるためのリストを取得
  static targets = ["input","list"];  
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
    const radius = parseInt(this.inputTarget.value, 10)
    if (this.checkRadius(radius)){
      // Railsにデータを送信
      this.sendLocation(lat, lon, radius)
    }
    else{
      return;
    }
  }

  error(err){
    console.error("error:" + err.message)
    alert("位置情報の取得に失敗しました")
  }

  checkRadius(radius){
    // 数値であるかの判定
    if (isNaN(radius)){
      alert("半径は数値で入力してください")
      return false;
    }
    // 許可する半径は1kmから50kmまで
    const allowedRadius = Array.from({length:50}, (_,i) => (i+1)*1000);
    if (!allowedRadius.includes(radius)){
      alert("半径は1kmから50kmまでの間で入力してください")
      return false;
    }
    return true;
  }
  

  // データ送信メソッド
  sendLocation(lat, lon, radius){
    // Railsのcontrollerに送信
    fetch('/destinations/get_location', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      },
      body: JSON.stringify({destination: {lat, lon, radius}})
    })
    .then(response => response.json())
    .then(data => {
      console.log(data)
      if (this.hasListTarget) { 
        // let stationElement = document.createElement("p");
        // stationElement.textContent = `緯度: ${data.latitude}, 経度: ${data.longitude}, 半径: ${data.radius}`;
        // this.listTarget.appendChild(stationElement);
      } else {
        console.error("listTarget が見つかりません");
      }
    })
    .catch((error) => {
      console.error('Error:', error);
    })
  }
}
