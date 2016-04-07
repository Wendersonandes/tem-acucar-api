module Endpoints
  class Notifications < Base
    namespace "/notifications" do
      before do
        authenticate!
      end

      get do
        limit = params['limit'] || 10
        offset = params['offset'] || 0
        filter = params['filter'] || 'read'
        notifications = current_user.notifications_dataset
        if filter == 'read'
          notifications = notifications.where(read: true)
          notifications = notifications.limit(limit).offset(offset)
        else
          notifications = notifications.where(read: false)
        end
        notifications = notifications.reverse(:created_at)
        encode serialize(notifications.all)
      end

      put "/read-all" do
        current_user.notifications_dataset.where(read: false).update(read: true)
        encode([])
      end

      private

      def serialize(data, structure = :default)
        Serializers::Notification.new(structure).serialize(data)
      end
    end
  end
end
