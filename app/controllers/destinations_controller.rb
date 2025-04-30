class DestinationsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :location_session_delete, only: %i[select_stations suggest_station move]

  # locationを取得するページ
  def now_location
    if request.get?
      @location = Location.new
    elsif request.post?
      location = Location.new(location_params)
      @stations = location.get_stations

      if @stations.blank?
        flash[:alert] = "指定の範囲では駅が見つかりませんでした。"
        redirect_to now_location_destinations_path
      else
        # セッションに初期位置を保存
        session[:pre_location] = { latitude: location.latitude, longitude: location.longitude }
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
      if params[:station].nil?
        flash[:alert] = "駅が選択されていません。"
        redirect_to select_stations_destinations_path
      else
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
  end

  # 行き先を表示するページ
  def suggest_station
    # セッションから情報を取得
    if request.get?
      @suggest_station = session[:suggest_station]
      @pre_location = session[:pre_location]
    elsif request.post?
      session[:decide_station] = session[:suggest_station]
      # 時間を登録
      session[:pre_time] = Time.now
      redirect_to move_destinations_path
    end
  end

  # 移動中のページ
  def move
    # セッションから情報を取得
    if request.get?
      @decide_station = session[:decide_station]
    elsif request.post?
      current_lat = params[:latitude].to_f
      current_lon = params[:longitude].to_f
      pre_lat = session[:pre_location]["latitude"].to_f
      pre_lon = session[:pre_location]["longitude"].to_f
      pre_time = Time.parse(session[:pre_time])
      current_time = Time.now

      # 移動距離の計算
      move_distance = Location.distance(current_lat, current_lon, pre_lat, pre_lon)

      # 不正移動検知
      if Location.moving_invalid?(pre_time, current_time, move_distance)
        # 不正移動
        flash[:alert] = "不正移動を検知しました。"
        redirect_to now_location_destinations_path
      else
        # 正常移動
        # 目的地からの移動距離
        decide_lat = session[:decide_station]["latitude"].to_f
        decide_lon = session[:decide_station]["longitude"].to_f
        distance = Location.distance(current_lat, current_lon, decide_lat, decide_lon)
        # 目的地から300m以内にいるか
        if Location.in_radius?(move_distance)
          # 目的地に到着
          redirect_to new_checkin_path
        else
          # セッションに現在地を保存
          session[:pre_location] = { latitude: current_lat, longitude: current_lon }
          session[:pre_time] = current_time
          flash[:notice] = "あと#{distance.round(2)}km!"
          redirect_to move_destinations_path
        end
      end
    end
  end

  private

  def location_params
    params.require(:location).permit(:latitude, :longitude, :radius)
  end
end
