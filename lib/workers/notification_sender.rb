module Workers
  class NotificationSender < Base
    def perform(notification_id)
      notification = ::Notification[notification_id]
      return unless notification
      notification.send_apn_notification!
      notification.send_gcm_notification!
      user = notification.user
      return unless user.email_notifications
      return unless user.authentications_dataset.count > 0
      Workers::Email.perform_async(user.id, notification.subject, notification.text)
    end
  end
end
