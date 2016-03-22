class Serializers::Demand < Serializers::Base
  structure(:default) do |arg|
    {
      id: arg.id,
      user: Serializers::User.new(:default).serialize(arg.user),
      state: arg.state,
      name: arg.name,
      description: arg.description,
      distance: arg.values[:distance],
      created_at: arg.created_at.try(:iso8601),
      updated_at: arg.updated_at.try(:iso8601),
    }
  end

  structure(:current_user) do |arg|
    {
      id: arg.id,
      user: Serializers::User.new(:default).serialize(arg.user),
      state: arg.state,
      name: arg.name,
      description: arg.description,
      latitude: arg.latitude,
      longitude: arg.longitude,
      radius: arg.radius,
      distance: 0,
      created_at: arg.created_at.try(:iso8601),
      updated_at: arg.updated_at.try(:iso8601),
    }
  end
end
