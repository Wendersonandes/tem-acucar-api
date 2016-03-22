module Endpoints
  class Messages < Base
    namespace "/messages" do
      before do
        authenticate!
      end

      post do
        message = Message.new(body_params)
        message.user = current_user
        message.save
        status 201
        encode serialize(message)
      end

      private

      def serialize(data, structure = :default)
        Serializers::Message.new(structure).serialize(data)
      end
    end
  end
end
