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
        if filter == 'admin'
          raise Pliny::Errors::Forbidden unless current_user.admin
          demands = Demand.reverse(:created_at)
        elsif filter == 'flagged'
          raise Pliny::Errors::Forbidden unless current_user.admin
          demands = Demand.with_state(:flagged).reverse(:updated_at)
        elsif filter == 'neighborhood'
          demands = current_user.neighborhood_demands
        elsif filter == 'user'
          demands = current_user.demands_dataset.reverse(:updated_at)
        elsif filter == 'transactions'
          demands = current_user.demands_with_transactions
        end
        demands = demands.limit(limit).offset(offset).all
        if filter == 'transactions'
          demands = demands.map do |demand|
            if demand.user == current_user
              transactions = demand.transactions
            else
              transactions = demand.transactions_dataset.where(user: current_user).all
            end
            transactions = Serializers::Transaction.new(:default).serialize(transactions)
            serialize(demand).merge({transactions: transactions}) 
          end
          encode demands
        else
          encode serialize(demands)
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

      put "/:id/complete" do |id|
        demand = Demand.first(id: id)
        raise Pliny::Errors::NotFound unless demand
        raise Pliny::Errors::Forbidden unless demand.user == current_user || current_user.admin
        demand.complete!
        encode serialize(demand, :current_user)
      end

      put "/:id/cancel" do |id|
        demand = Demand.first(id: id)
        raise Pliny::Errors::NotFound unless demand
        raise Pliny::Errors::Forbidden unless demand.user == current_user || current_user.admin
        demand.cancel!
        encode serialize(demand, :current_user)
      end

      put "/:id/reactivate" do |id|
        demand = Demand.first(id: id)
        raise Pliny::Errors::NotFound unless demand
        raise Pliny::Errors::Forbidden unless demand.user == current_user || current_user.admin
        raise Pliny::Errors::Forbidden if demand.state == 'flagged' && !current_user.admin
        demand.reactivate!
        encode serialize(demand, :current_user)
      end

      private

      def serialize(data, structure = :default)
        Serializers::Demand.new(structure).serialize(data)
      end
    end
  end
end
