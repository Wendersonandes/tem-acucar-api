module Endpoints
  class Refusals < Base
    namespace "/refusals" do
      before do
        authenticate!
      end

      post do
        refusal = Refusal.new(body_params)
        refusal.user = current_user
        refusal.save
        status 201
        encode serialize(refusal)
      end

      private

      def serialize(data, structure = :default)
        Serializers::Refusal.new(structure).serialize(data)
      end
    end
  end
end
