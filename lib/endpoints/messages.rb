module Endpoints
  class Messages < Base
    namespace "/messages" do
      before do
        authenticate!
      end

      get do
        transaction = Transaction[params['transaction_id']]
        raise Pliny::Errors::Forbidden unless [transaction.user, transaction.demand.user].include?(current_user)
        limit = params['limit'] || 10
        offset = params['offset'] || 0
        messages = transaction.messages_dataset.reverse(:created_at)
        encode serialize(messages.limit(limit).offset(offset).all)
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
