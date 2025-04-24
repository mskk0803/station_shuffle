import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="display-maps"
export default class extends Controller {

  static targets = ["map", "latitude", "longitude"]
  
  connect() {
    
  }
}
