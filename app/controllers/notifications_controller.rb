class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.includes(:notifiable).order(created_at: :desc)

    # 未読の通知を既読にする
    current_user.mark_all_notifications_as_read
  end
end
