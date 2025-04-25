class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, :location_session_delete

  # 位置情報系のセッションを消す
  def location_session_delete
    session[:pre_location] = nil
    session[:stations] = nil
    session[:suggest_station] = nil
    session[:decide_station] = nil
    session[:pre_time] = nil
  end
end
