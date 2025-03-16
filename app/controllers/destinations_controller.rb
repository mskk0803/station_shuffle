class DestinationsController < ApplicationController
  def new
  end

  def get_location
    # 2025-03-15 destinationの位置情報取得処理
    # 位置情報を取得するためのパラメータを取得
    # 一応、意図しないデータが送られてきた場合のために、ストロングパラメーターにしておく
    location_params = params.require(:destination).permit(:lat, :lon, :radius)
    lat = location_params[:lat]
    lon = location_params[:lon]
    radius = location_params[:radius].to_i

    render json: { latitude: lat, longitude: lon , radius: radius }
  end

  # APIで駅を取得する
  def get_stations(lat, lon, radius)
    client = GooglePlaces::Client.new(ENV['GOOGLE_API_KEY'])


  end
end
