module Workers
  class DemandActivator < Base
    def perform(demand_id)
      demand = Demand[demand_id]
      return unless demand && demand.state == 'notifying'
      demand.activate!
    end
  end
end
