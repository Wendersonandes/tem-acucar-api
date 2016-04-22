module Workers
  class DemandUserNotifier < Base
    def perform(demand_id, user_id)
      demand = Demand[demand_id]
      user = User[user_id]
      return unless user && demand && demand.state == 'notifying'
      Notification.create({
        user: user,
        triggering_user: demand.user,
        demand: demand,
        text: "Você por acaso teria um(a) <b>#{demand.name}</b> para emprestar? <b>#{demand.user.first_name}</b> está pedindo.\n\n<i>\"#{demand.description}\"</i>",
      })
    end
  end
end
