module Endpoints
  class Demands < Base
    namespace "/demands" do
      before do
        authenticate!
      end

      get do
        limit = params['limit'] || 10
        offset = params['offset'] || 0
        filter = params['filter'] || 'neighborhood'
        if filter == 'neighborhood'
          demands = current_user.neighborhood_demands
        elsif filter == 'transactions'
          demands = current_user.demands_with_transactions
        end
        demands = demands.limit(limit).offset(offset).all
        if filter == 'neighborhood'
          encode serialize(demands)
        elsif filter == 'transactions'
          demands = demands.map do |demand|
            if demand.user == current_user
              transactions = demand.transactions
            else
              transactions = demand.transactions_dataset.where(user: current_user)
            end
            transactions = Serializers::Transaction.new(:default).serialize(transactions.all)
            serialize(demand).merge({transactions: transactions}) 
          end
          encode demands
        end
      end

      post do
        demand = Demand.new(body_params)
        demand.user = current_user
        demand.latitude = current_user.latitude
        demand.longitude = current_user.longitude
        demand.radius = 1
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
