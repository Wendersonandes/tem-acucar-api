module Workers
  class DemandNotifier < Base
    def perform(demand_id)
      demand = Demand[demand_id]
      return unless demand && demand.state == 'notifying'
      users = User.where("id <> '#{demand.user.id}'").near([demand.latitude, demand.longitude], demand.radius, units: :km)
      count = users.count
      seconds = 0
      factor = 1.0
      users.each_with_index do |user, index|
        beginningness = 1 - ((index + 1) / count.to_f)
        seconds = (index + ((index * beginningness) * factor)).round
        Workers::DemandUserNotifier.perform_in(seconds, demand.id, user.id)
      end
      Workers::DemandActivator.perform_in((seconds + 10), demand.id)
    end
  end
end
