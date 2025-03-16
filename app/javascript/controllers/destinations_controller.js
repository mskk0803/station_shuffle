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
      console.log(data.stations)
      console.log(!data.stations.length)
      if (this.hasListTarget) { 
        // リストが空の場合
        // 参考：https://www.freecodecamp.org/japanese/news/check-if-javascript-array-is-empty-or-not-with-length/
        if (!data.stations.length){
          this.listTarget.innerHTML = "";
          const noStationsTextEle = document.createElement("p");
          noStationsTextEle.textContent = "指定の検索範囲では駅が見つかりませんでした。"
          this.listTarget.appendChild(noStationsTextEle);
        }else{
          this.updateStationList(data.stations);
        }
      }
    })
    .catch((error) => {
      console.error('Error:', error);
    })
  }

  // 駅リストの更新関数
  updateStationList(stations){
    this.listTarget.innerHTML = "";
    stations.forEach((stationName) => {
      this.listTarget.appendChild(this.createCheckbox(stationName))
    })

  }

  // チェックボックス生成
  createCheckbox(stationName){
    const divElement = document.createElement("div");
    const checkBoxElement = document.createElement("input");
    const labelElement = document.createElement("label");

    checkBoxElement.type = "checkbox";
    checkBoxElement.id = stationName;
    checkBoxElement.name = "stations";
    checkBoxElement.value = stationName;

    labelElement.htmlFor = stationName;
    labelElement.textContent = stationName;

    divElement.appendChild(checkBoxElement);
    divElement.appendChild(labelElement);

    return divElement;
  }
}
