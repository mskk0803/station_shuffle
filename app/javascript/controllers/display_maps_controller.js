import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="display-maps"
export default class extends Controller {
  static targets = ["map", "latitude", "longitude", "name", "preLat", "preLon"]
;
  connect() {
    const latitude = parseFloat(this.latitudeTarget.value)
    const longitude = parseFloat(this.longitudeTarget.value)
    const name = this.nameTarget.value
    const preLat = parseFloat(this.preLatTarget.value)
    const preLon = parseFloat(this.preLonTarget.value)

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

    // 参考URL：https://qiita.com/Boukenkayuta/items/9775aa550905163f0354
    const currentPosition = { lat: preLat, lng: preLon } // 東京駅の位置
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
  }
}

