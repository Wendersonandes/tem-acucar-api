module Workers
  class Notification < Base
    def perform(notification_id)
      notification = ::Notification[notification_id]
      return unless notification
      notification.send_gcm_notification!
    end
  end
end
