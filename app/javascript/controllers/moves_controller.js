import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="moves"
export default class extends Controller {

  static targets = ["currentLat", "currentLon", "stationLat", "stationLon", "name", "map", "button"]

  connect() {
    console.log("Connection Start")
    window.requestAnimationFrame(() => {
      this.getCurrentLocation()
    })
  }

  getCurrentLocation(){
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          const currentLat = position.coords.latitude
          const currentLon = position.coords.longitude

          const stationLat = parseFloat(this.stationLatTarget.value)
          const stationLon = parseFloat(this.stationLonTarget.value)
          const name = this.nameTarget.value
          const stationPositon = { lat: stationLat, lng: stationLon }
          const currentPosition = { lat: currentLat, lng: currentLon } // 東京駅の位置
          this.map = new google.maps.Map(this.mapTarget, {
            zoom: 15,
            center: currentPosition,
          })
      
          new google.maps.Marker({
            position: stationPositon,
            map: this.map,
            title: name,
          })

          // 参考URL：https://qiita.com/Boukenkayuta/items/9775aa550905163f0354
          console.log(currentPosition)
          //縁の薄い青丸
          new google.maps.Circle({
            strokeColor: '#115EC3',
            strokeOpacity: 0.2,
            strokeWeight: 1,
            fillColor: '#115EC3',
            fillOpacity: 0.2,
            map: this.map,
            center: currentPosition,
            radius: 100
            });        
          //  中央の濃い青丸
          new google.maps.Marker({
              position: currentPosition,
              map: this.map,
              icon: {
                path: google.maps.SymbolPath.CIRCLE,
                fillColor: '#115EC3',
                fillOpacity: 1,
                strokeColor: 'white',
                strokeWeight: 2,
                scale: 7
              }, 
            });
          this.currentLatTarget.value = currentLat
          this.currentLonTarget.value = currentLon
        },
        (error) => {
          console.error("位置情報の取得に失敗しました:", error)
        },
          {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 0
          }
      )
    } else {
      console.error("このブラウザでは位置情報がサポートされていません。")
    }
  }
}
