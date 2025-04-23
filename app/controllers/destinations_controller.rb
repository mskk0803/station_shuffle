class DestinationsController < ApplicationController
  skip_before_action :authenticate_user!

  # locationを取得するページ
  def now_location
    if request.get?
      @location = Location.new
    elsif request.post?
      location = Location.new(location_params)
      @stations = location.get_stations

      if @stations.blank?
        flash.now[:alert] = "指定の範囲では駅が見つかりませんでした。"
        render :now_location
      else
        # セッションに初期位置を保存
        session[:current_location] = { latitude: location.latitude, longitude: location.longitude }
        # 駅データを保存
        session[:stations] = @stations.map { |station| { name: station.name, latitude: station.latitude, longitude: station.longitude } }
        redirect_to select_stations_destinations_path
      end
    end
  end

  # 駅を選択するページ
  # ポストで渡すのはアンチパターン
  # 参考URL：https://qiita.com/yuyasat/items/49e3296f3c64fccc7811
  def select_stations
    # セッションから駅情報を取得
    if request.get?
      @stations = session[:stations].map do |station|
        Station.new(station)
      end
    elsif request.post?
      # Ary
      selected_stations = params[:station][:names]
      # シャッフル
      decide_station = selected_stations.shuffle.first

      # 文字列で探す
      station = session[:stations].find { |station| station["name"] == decide_station }

      # セッションに保存
      session[:suggest_station] = station
      redirect_to suggest_station_destinations_path
    end
  end

  # 行き先を表示するページ
  def suggest_station
    # セッションから情報を取得
    if request.get?
      @suggest_station = session[:suggest_station]
    elsif request.post?
      session[:decide_station] = session[:suggest_station]
      # 提案情報は破棄
      session[:suggest_station] = nil
      redirect_to move_destinations_path
    end
  end

  # 移動中のページ
  def move

  end

  private

  def location_params
    params.require(:location).permit(:latitude, :longitude, :radius)
  end

end
