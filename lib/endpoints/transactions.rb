module Endpoints
  class Transactions < Base
    namespace "/transactions" do
      before do
        authenticate!
      end

      post do
        transaction = Transaction.new(body_params)
        transaction.user = current_user
        transaction.save
        status 201
        encode serialize(transaction)
      end

      private

      def serialize(data, structure = :default)
        Serializers::Transaction.new(structure).serialize(data)
      end
    end
  end
end
