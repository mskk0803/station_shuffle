import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="destinations"
export default class extends Controller {

  // 入力フォームと表示させるためのターゲットを取得
  static targets = ["input","list", "result","all"];  

  // value定義
  static values = {
    stationName: String
  }

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
    // ここをもっと疎にする
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
    // Arayfromで配列に変える
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
          // リストが空でない場合に、チェックボックスを追加
          this.updateStationList(data.stations);
          // シャッフルボタンの作成関数
          this.createShuffleButton();
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
    checkBoxElement.name = "station";
    checkBoxElement.value = stationName;

    labelElement.htmlFor = stationName;
    labelElement.textContent = stationName;

    divElement.appendChild(checkBoxElement);
    divElement.appendChild(labelElement);

    return divElement;
  }

  // シャッフルボタンの作成関数
  createShuffleButton(){
    const shuffleButton = document.createElement("button")
    shuffleButton.textContent = "行き先を決める！"
    shuffleButton.setAttribute("data-action","destinations#shuffleStation")
    this.listTarget.appendChild(shuffleButton)
  }

  // 駅をシャッフルする関数
  shuffleStation (){
    // HTML要素を削除する
    this.resultTarget.innerHTML = "";
    
    // 参考URL：https://developer.mozilla.org/ja/docs/Web/JavaScript/Reference/Global_Objects/Array/from
    const selectedStations = Array.from(this.listTarget.querySelectorAll("input[name='station']:checked"), (selected) => selected.value )

    if(!selectedStations.length) {
      alert("駅を選択してください。")
      return
    }
    const randomIndex = Math.floor(Math.random() * selectedStations.length )
    const station = selectedStations[randomIndex]

    const stationEle = document.createElement("p")
    stationEle.textContent = `行き先は${station}に決定しました。`
    this.resultTarget.appendChild(stationEle)

    const letsGoEle = document.createElement("button")
    letsGoEle.textContent = "この駅に行く！";
    // 参考：https://qiita.com/kaorumori/items/e944c21e4d32fec884c6
    // valueを追加
    letsGoEle.setAttribute("data-loader-stationName-value", `${station}`)
    letsGoEle.setAttribute("data-action","destinations#goToStation")
    this.resultTarget.appendChild(letsGoEle)
  }

  // この駅に行く、の後の画面
  goToStation(){
    this.allTarget.innerHTML = "";
    // 文言を追加
    const goToStationText = document.createElement("p")
    goToStationText.textContent = `${this.stationNameValue}へ移動中…`
    // ボタンを作成
    const updateGeoLocationButtuon = document.createElement("button")
    updateGeoLocationButtuon.textContent = "位置情報を更新！"
    updateGeoLocationButtuon.setAttribute("data-action","destinations#updateGeoLocation")

    // 子要素に追加
    this.allTarget.appendChild(goToStationText)
    this.allTarget.appendChild(updateGeoLocationButtuon)
  }

  // 位置情報の取得
  updateGeoLocation(){

  }

}
