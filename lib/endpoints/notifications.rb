module Endpoints
  class Notifications < Base
    namespace "/notifications" do
      before do
        authenticate!
      end

      get do
        limit = params['limit'] || 10
        offset = params['offset'] || 0
        notifications = current_user.notifications_dataset.reverse(:created_at)
        encode serialize(notifications.limit(limit).offset(offset).all)
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
