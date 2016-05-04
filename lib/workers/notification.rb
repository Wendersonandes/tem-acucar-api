module Workers
  class Notification < Base
    def perform(notification_id)
      notification = ::Notification[notification_id]
      return unless notification
      if notification.user.authentications_dataset.count > 0
        Workers::Email.perform_async(notification.user.id, notification.subject, notification.text)
      end
      notification.send_gcm_notification!
    end
  end
end
