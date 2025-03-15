class DestinationsController < ApplicationController
  def new
  end

  def get_location
    # 2025-03-15 destinationの位置情報取得処理
    # 位置情報を取得するためのパラメータを取得
    lat = params[:lat]
    lon = params[:lon]

    render json: { latitude: lat, longitude: lon }
  end

  # def get_stations

  # end
end
