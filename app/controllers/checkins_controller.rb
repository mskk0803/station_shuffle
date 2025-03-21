class CheckinsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    # ログインしているかどうかを確認
    if user_signed_in?
      checkin = current_user.checkins.build(checkin_params)

      # 参考URL：https://railsguides.jp/api_app.html
      if checkin.save!
        render json: checkin, status: :created
      else
        render json: checkin.errors, status: :unprocessable_entity
      end
    else
      render json: { text: "ログインするとチェックインの記録ができるようになります！" }
    end
  end

  private
  def checkin_params
    params.require(:checkin).permit(:station)
  end
end
