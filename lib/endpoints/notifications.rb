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

      put "/:id" do |id|
        notification = Notification.first(id: id)
        raise Pliny::Errors::NotFound unless notification
        raise Pliny::Errors::Forbidden unless notification.user == current_user
        begin
          notification.update(body_params)
          encode serialize(notification)
        rescue
          status 422
          errors(notification.errors.full_messages)
        end
      end

      private

      def serialize(data, structure = :default)
        Serializers::Notification.new(structure).serialize(data)
      end
    end
  end
end
