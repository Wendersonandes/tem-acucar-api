module Endpoints
  class Me < Base
    namespace "/me" do
      before do
        authenticate!
      end

      get do
        encode serialize(current_user, :current_user)
      end

      private

      def serialize(data, structure = :default)
        Serializers::User.new(structure).serialize(data)
      end
    end
  end
end
