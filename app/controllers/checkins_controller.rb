class CheckinsController < ApplicationController
  skip_before_action :authenticate_user!

  def new
    @stations = session[:decide_station]
  end

  def create
    # ログインしているかどうかを確認
    if user_signed_in?
      station_name = session[:decide_station]["name"]
      checkin = current_user.checkins.build(station: station_name)

      # 参考URL：https://railsguides.jp/api_app.html
      if checkin.save
        session_delete
        redirect_to posts_path, notice: "チェックインしました！"
      else
        flash.now[:alert] = "チェックインに失敗しました。"
        render :new, status: :unprocessable_entity
      end
    else
      session_delete
      redirect_to root_path, alert: "ログインするとチェックインができるようになります！"
    end
  end

  private
  def checkin_params
    params.require(:checkin).permit(:station)
  end

  def session_delete
    session[:pre_location] = nil
    session[:stations] = nil
    session[:suggest_station] = nil
    session[:decide_station] = nil
    session[:pre_time] = nil
  end
end
