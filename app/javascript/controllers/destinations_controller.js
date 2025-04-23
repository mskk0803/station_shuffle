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
}
