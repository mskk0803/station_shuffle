class CheckinsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :location_session_delete

  def new
    # セッションに情報があるか？
    if session[:decide_station].present?
      @station = session[:decide_station]["name"]
    else
      flash[:alert] = "現在地取得からやり直して下さい。"
      redirect_to now_location_destinations_path
    end
  end

  def create
    # ログインしているかどうかを確認
    if user_signed_in?
      station_name = session[:decide_station]["name"]
      checkin = current_user.checkins.build(station: station_name)

      # 参考URL：https://railsguides.jp/api_app.html
      if checkin.save
        # セッションを破棄
        location_session_delete
        redirect_to new_post_path, notice: "チェックインしました！"
      else
        flash.now[:alert] = "チェックインに失敗しました。"
        render :new, status: :unprocessable_entity
      end
    else
      # セッションを破棄
      location_session_delete
      redirect_to root_path, alert: "ログインするとチェックインができるようになります！"
    end
  end

  private
  def checkin_params
    params.require(:checkin).permit(:station)
  end
end
