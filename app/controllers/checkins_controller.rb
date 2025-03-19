class CheckinsController < ApplicationController
  def create
    checkin = current_user.checkins.build(checkin_params)

    # 参考URL：https://railsguides.jp/api_app.html
    if checkin.save!
      render json: checkin, status: :created
    else
      render json: checkin.errors, status: :unprocessable_entity
    end
  end

  private
  def checkin_params
    params.require(:checkin).permit(:station)
  end
end
