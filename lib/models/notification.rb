class Notification < Sequel::Model
  plugin :timestamps, update_on_create: true
  plugin :auto_validations, not_null: :presence

  many_to_one :user
  many_to_one :triggering_user, class: :User, key: :triggering_user_id
  many_to_one :demand
  many_to_one :transaction
  many_to_one :message
  many_to_one :review

  def after_create
    super
    Workers::NotificationSender.perform_in(1, self.id)
  end

  def send_apn_notification!
    return unless self.user.app_notifications
    token = self.user.apn_token
    return unless token
    if Config.pliny_env == 'production'
      # apn = Houston::Client.production
      apn = Houston::Client.development
    else
      apn = Houston::Client.development
    end
    notification = Houston::Notification.new(token: token)
    notification.alert = self.subject
    notification.sound = ''
    notification.badge = self.user.notifications_dataset.where(read: false).count
    notification.content_available = true
    notification.custom_data = Serializers::Notification.new(:default).serialize(self).merge({
      app_notifications: self.user.app_notifications,
      sanitized_text: Sanitize.clean(self.text),
    })
    apn.push(notification)
    notification
  end

  def send_gcm_notification!
    token = self.user.gcm_token
    return unless token
    gcm = GCM.new(Config.gcm_api_key)
    options = { data: Serializers::Notification.new(:default).serialize(self).merge({
      app_notifications: self.user.app_notifications,
      sanitized_text: Sanitize.clean(self.text),
    })}
    response = gcm.send([token], options)
  end
end
