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

    // session保存
    this.setSession(lat,lon)

    const radius = parseInt(this.inputTarget.value, 10)
    if (this.checkRadius(radius)){
      // Railsにデータを送信
      this.sendLocation(lat, lon, radius)
    }
    else{
      return;
    }
  }

  // セッション保存関数
  setSession(lat, lon){
    // 1970 年 1 月 1 日 0 時 0 分 0 秒 から現在までの経過時間をミリ秒単位で取得
    const time = Date.now();

    // 参考URL：https://qiita.com/uralogical/items/ade858ccfa164d164a3b
    // 文字列として保存される
    sessionStorage.lat = lat;
    sessionStorage.lon = lon;
    sessionStorage.time = time;
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
    // 許可する半径は1kmから5kmまで
    // Arayfromで配列に変える
    const allowedRadius = Array.from({length:5}, (_,i) => (i+1)*1000);
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
    stations.forEach((station) => {
      this.listTarget.appendChild(this.createCheckbox(station))
    })
  }

  // チェックボックス生成
  createCheckbox(station){
    const divElement = document.createElement("div");
    const checkBoxElement = document.createElement("input");
    const labelElement = document.createElement("label");

    checkBoxElement.type = "checkbox";
    checkBoxElement.id = station.name;
    checkBoxElement.name = "station";
    checkBoxElement.value = station.name;
    // 緯度経度の情報を持たせる
    checkBoxElement.dataset.lat = station.lat;
    checkBoxElement.dataset.lon = station.lon;

    labelElement.htmlFor = station.name;
    labelElement.textContent = station.name;

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
    const selectedStations = Array.from(this.listTarget.querySelectorAll("input[name='station']:checked"), 
                            (selected) => ({
                              name: selected.value,
                              lat: selected.dataset.lat,
                              lon: selected.dataset.lon
                            }))

    if(!selectedStations.length) {
      alert("駅を選択してください。")
      return
    }
    const randomIndex = Math.floor(Math.random() * selectedStations.length )
    const station = selectedStations[randomIndex].name
    const lat = selectedStations[randomIndex].lat
    const lon = selectedStations[randomIndex].lon

    const stationEle = document.createElement("p")
    stationEle.textContent = `行き先は${station}に決定しました。`
    this.resultTarget.appendChild(stationEle)

    const letsGoEle = document.createElement("button")
    letsGoEle.textContent = "この駅に行く！";
    // 参考：https://qiita.com/kaorumori/items/e944c21e4d32fec884c6
    // sessionに保存
    sessionStorage.stationName = station
    sessionStorage.stationLat = lat
    sessionStorage.stationLon = lon

    letsGoEle.setAttribute("data-action","destinations#goToStation")
    this.resultTarget.appendChild(letsGoEle)
  }

  // この駅に行く、の後の画面
  goToStation(){
    this.allTarget.innerHTML = "";
    // 文言を追加
    const stationName = sessionStorage.getItem("stationName")
    const goToStationText = document.createElement("p")
    goToStationText.textContent = `${stationName}へ移動中…`
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
    navigator.geolocation.getCurrentPosition(
      this.updateSuccess.bind(this),
      this.error.bind(this)
    )
  }

  updateSuccess(position){
    const currentLat = position.coords.latitude
    const currentLon = position.coords.longitude
    const currentTime = Date.now()

    // 不正移動検知 true なら不正でない
    if (this.checkMovingValidation(currentLat, currentLon, currentTime)){
      // 300m以内ならチェックイン可能
      console.log("駅の取得:",this.stationLatValue)
      const stationName = sessionStorage.getItem("stationName")
      const stationLat = parseFloat(sessionStorage.getItem("stationLat"))
      const stationLon = parseFloat(sessionStorage.getItem("stationLon"))

      const distance = this.getDistanse(currentLat, currentLon, stationLat, stationLon)
      if(distance * 1000 <= 300){
        // チェックインボタンを表示
        this.allTarget.innerHTML = "";
        const checkinText = document.createElement("p")
        checkinText.textContent = `${stationName}に到着！`

        // checkinButton
        const checkinButton = document.createElement("button")
        checkinButton.textContent = "チェックイン！"
        checkinButton.setAttribute("data-action", "destinations#sendData")

      }else{
        // チェックイン可能でない場合
        // 残りdistanceを表示
        this.allTarget.innerHTML = "";
        const goToStationText = document.createElement("p")
        goToStationText.textContent = `${stationName}へ移動中…`
        const distanceText = document.createElement("p")

        // 四捨五入
        let aroundDistance = distance*100
        aroundDistance = Math.round(aroundDistance) / 100

        distanceText.textContent = `${stationName}まで、残り約${aroundDistance}km`
        // ボタンを作成
        const updateGeoLocationButtuon = document.createElement("button")
        updateGeoLocationButtuon.textContent = "位置情報を更新！"
        updateGeoLocationButtuon.setAttribute("data-action","destinations#updateGeoLocation")

        // 子要素に追加
        this.allTarget.appendChild(goToStationText)
        this.allTarget.appendChild(distanceText)
        this.allTarget.appendChild(updateGeoLocationButtuon)

      }

    } else {
      return 
    }
  }
  
  // 不正移動検知関数
  checkMovingValidation(currentLat, currentLon, currentTime){
    // 前回の値を取得して文字列から数値型に変換する
    let preLat = sessionStorage.getItem("lat")
    let preLon = sessionStorage.getItem("lon")
    let preTime = sessionStorage.getItem("time")

    // 存在確認
    if(preLat && preLon && preTime ){
      preLat = parseFloat(preLat)
      preLon = parseFloat(preLon)
      preTime = parseInt(preTime, 10)

      // 速度計算
      // km
      const distance = this.getDistanse(currentLat, currentLon, preLat, preLon)  
      // 秒数
      const time = (currentTime - preTime) / 1000;  
      // 新幹線：秒速8㎞で計算
      const speed = distance / time;
      if(speed > 8){
          alert("不正移動が検出されました。TOP画面に戻ります。")
          window.location.href = "/";
          return false;
      } 
      return true
    }
    return true
  }


  // 緯度と経度から距離を計算する関数 
  // 参考URL：https://qiita.com/kawanet/items/a2e111b17b8eb5ac859a
  // 計算式：https://www.movable-type.co.uk/scripts/latlong.html
  // 公式：Haversineの公式
  getDistanse(lat, lon, preLat, preLon){

    // 赤道半径(km)
    const EARTHRAD =  6378.137;

    // 角度をラジアンに変換
    const toRad = (a) => a * (Math.PI / 180);

    const lat1 = toRad(preLat)
    const lon1 = toRad(preLon)
    const lat2 = toRad(lat)
    const lon2 = toRad(lon)

    // 差分計算
    const dLat = lat2 - lat1
    const dLon = lon2 - lon1

    const a = Math.sin(dLat / 2)**2 +
              Math.cos(lat1) * Math.cos(lat2)  *Math.sin(dLon / 2)**2

    const c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a) )

    const distance = EARTHRAD * c

    return distance;
  }

  // Railsにチェックインした駅を送る関数
  sendData(){
    const stationName = sessionStorage.getItem("stationName")
    
    // 送信
    fetch("/checkin/create", {
      method: "Post",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({destination: {stationName}})
    })
    .then(response => {
      if(!response.ok){
        alert("チェックインに失敗しました。")
      }
      return response.json();
    })
    .then(data => {
      // ログインしている場合とそうでない場合に遷移を分ける
      alert("チェックイン成功！")
      // 投稿ページに遷移
      window.location.href = `/post/new`
    })
    .catch((error) => {
      console.error('Error:', error);
      alert("エラーが発生しました。")
    })
  }
}
