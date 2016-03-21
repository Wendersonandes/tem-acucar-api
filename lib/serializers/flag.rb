class Serializers::Flag < Serializers::Base
  structure(:default) do |arg|
    {
      id: arg.id,
      demand: Serializers::Demand.new(:default).serialize(arg.demand),
      user: Serializers::User.new(:default).serialize(arg.user),
      created_at: arg.created_at.try(:iso8601),
      updated_at: arg.updated_at.try(:iso8601),
    }
  end
end
