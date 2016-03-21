module Endpoints
  class Demands < Base
    namespace "/demands" do
      before do
        authenticate!
      end

      get do
        limit = params['limit'] || 10
        offset = params['offset'] || 0
        encode serialize(current_user.neighbor_demands.limit(limit).offset(offset).all)
      end

      post do
        demand = Demand.new(body_params)
        demand.user = current_user
        demand.latitude = current_user.latitude
        demand.longitude = current_user.longitude
        demand.save
        status 201
        encode serialize(demand, :current_user)
      end

      private

      def serialize(data, structure = :default)
        Serializers::Demand.new(structure).serialize(data)
      end
    end
  end
end
